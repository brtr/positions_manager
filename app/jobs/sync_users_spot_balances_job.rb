class SyncUsersSpotBalancesJob < ApplicationJob
  queue_as :daily_job

  def perform(user_id=nil)
    if user_id
      sync_user_spot_balances(user_id)
    else
      user_ids = User.where('api_key is not null and secret_key is not null').ids
      user_ids.each do |user_id|
        sync_user_spot_balances(user_id)
      end
    end

    ForceGcJob.perform_later
  end

  def sync_user_spot_balances(user_id)
    maximum_tx_id = UserSpotBalance.where(user_id: user_id).maximum(:tx_id).to_i
    OriginTransaction.available.where('user_id = ? and id > ?', user_id, maximum_tx_id).group_by{|tx| [tx.original_symbol, tx.to_symbol, tx.source]}.each do |key, txs|
      from_symbol = key[0].split(key[1])[0]
      usb = UserSpotBalance.where(user_id: user_id, origin_symbol: key[0], from_symbol: from_symbol, to_symbol: key[1], source: key[2]).first_or_initialize
      total_cost = usb.amount.to_f
      total_qty = usb.qty.to_f
      # 只有买单才会更新成本价和总金额
      txs.select{|tx| tx.trade_type == 'buy'}.each do |tx|
        total_cost += tx.amount
        total_qty += tx.qty
      end

      price = total_qty.zero? ? 0 : total_cost / total_qty

      # 卖单只更新数量和总金额
      sold_qty = txs.select{|tx| tx.trade_type == 'sell'}.sum(&:qty)
      total_qty -= sold_qty
      total_cost = total_qty * price

      usb.update(price: price, qty: total_qty, amount: total_cost, tx_id: txs.max_by(&:id).id)
    end
  end
end
