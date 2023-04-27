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
    OriginTransaction.where(user_id: user_id, event_time: Date.yesterday.all_day).group_by{|tx| [tx.original_symbol, tx.to_symbol, tx.source]}.each do |key, txs|
      from_symbol = key[0].split(key[1])[0]
      usb = UserSpotBalance.where(user_id: user_id, origin_symbol: key[0], from_symbol: from_symbol, to_symbol: key[1], source: key[2]).first_or_initialize
      total_cost = usb.amount.to_f
      total_qty = usb.qty.to_f
      txs.each do |tx|
        if tx.trade_type == 'buy'
          total_cost += tx.amount
          total_qty += tx.qty
        else
          total_cost -= tx.amount
          total_qty -= tx.qty
        end
      end
      price = total_cost / total_qty
      usb.update(price: price, qty: total_qty, amount: total_cost)
    end
  end
end
