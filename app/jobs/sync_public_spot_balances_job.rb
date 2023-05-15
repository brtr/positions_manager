class SyncPublicSpotBalancesJob < ApplicationJob
  queue_as :daily_job

  def perform
    OriginTransaction.where('user_id is null and original_symbol = ?', 'BTCUSDT').group_by{|tx| [tx.original_symbol, tx.to_symbol, tx.source]}.each do |key, txs|
      from_symbol = key[0].split(key[1])[0]
      usb = UserSpotBalance.where(user_id: nil, origin_symbol: key[0], from_symbol: from_symbol, to_symbol: key[1], source: key[2]).first_or_initialize
      total_cost = 0
      total_qty = 0
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

    ForceGcJob.perform_later
  end
end
