class GenerateOriginTransactionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = TransactionsSnapshotInfo.where(event_date: date).first_or_create
    generate_snapshot(snapshot_info)
  end

  def generate_snapshot(snapshot_info)
    TransactionsSnapshotRecord.transaction do
      txs = OriginTransaction.where(trade_type: 'buy')
      txs.each do |tx|
        snap_shot = snapshot_info.snapshot_records.where(order_id: tx.order_id, original_symbol: tx.original_symbol, trade_type: tx.trade_type, event_time: tx.event_time, source: tx.source).first_or_create
        snap_shot.update(from_symbol: tx.from_symbol, to_symbol: tx.to_symbol, fee_symbol: tx.fee_symbol, qty: tx.qty, price: tx.price, fee: tx.fee,
                         amount: tx.amount, current_price: tx.current_price, revenue: tx.revenue, roi: tx.roi, campaign: tx.campaign)
      end
    end
  end
end
