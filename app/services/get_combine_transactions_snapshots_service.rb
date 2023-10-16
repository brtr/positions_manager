class GetCombineTransactionsSnapshotsService
  class << self
    def execute
      from_date = Date.parse('2023-01-01')
      to_date = Date.current
      txs = OriginTransaction.year_to_date.available.where(user_id: nil)

      (from_date..to_date).each do |date|
        info = CombineTxSnapshotInfo.where(event_date: date).first_or_create
        last_info = CombineTxSnapshotInfo.where(event_date: date - 1.day).first_or_create
        ids = []
        txs.where(event_time: date.all_day).group_by(&:original_symbol).each do |original_symbol, origin_txs|
          record = last_info.combine_tx_snapshot_records.find_by(original_symbol: original_symbol)
          ids.push(record.id) if record
          total_cost = record&.amount.to_f
          total_qty = record&.qty.to_f
          total_fee = record&.fee.to_f
          total_sold_revenue = record&.sold_revenue.to_f

          origin_txs.each do |tx|
            if tx.trade_type == 'buy'
              total_cost += tx.amount
              total_qty += tx.qty
            else
              total_cost -= tx.amount
              total_qty -= tx.qty
              total_sold_revenue += tx.revenue
            end

            total_fee += tx.fee
          end

          origin_tx = origin_txs.first
          trade_type = total_cost > 0 ? 'buy' : 'sell'
          combine_tx = info.combine_tx_snapshot_records.where(source: origin_tx.source, original_symbol: original_symbol, from_symbol: origin_tx.from_symbol, to_symbol: origin_tx.to_symbol,
                                                              fee_symbol: origin_tx.fee_symbol, trade_type: trade_type).first_or_create

          price = total_cost / total_qty
          revenue = trade_type == 'buy' ? origin_tx.current_price * total_qty - total_cost : total_cost.abs - origin_tx.current_price * total_qty
          roi = revenue / total_cost.abs

          combine_tx.update(price: price, qty: total_qty, amount: total_cost, fee: total_fee, current_price: origin_tx.current_price, revenue: revenue, roi: roi, sold_revenue: total_sold_revenue)
        end

        last_info.combine_tx_snapshot_records.where.not(id: ids).each do |record|
          new_snapshot = record.dup
          new_snapshot.id = nil
          new_snapshot.combine_tx_snapshot_info = info
          new_snapshot.save
        end
      end
    end
  end
end
