class GenerateOriginTransactionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = TransactionsSnapshotInfo.where(event_date: date).first_or_create
    generate_snapshot(snapshot_info)
    ForceGcJob.perform_later
  end

  def generate_snapshot(snapshot_info)
    txs = OriginTransaction.where(trade_type: 'buy')

    txs.find_each(batch_size: 100) do |tx|
      TransactionsSnapshotRecord.transaction do
        snap_shot = snapshot_info.snapshot_records.find_or_create_by(order_id: tx.order_id, original_symbol: tx.original_symbol, trade_type: tx.trade_type, event_time: tx.event_time, source: tx.source)
        snap_shot.update(from_symbol: tx.from_symbol, to_symbol: tx.to_symbol, fee_symbol: tx.fee_symbol, qty: tx.qty, price: tx.price, fee: tx.fee,
                         amount: tx.amount, current_price: tx.current_price, revenue: tx.revenue, roi: tx.roi, campaign: tx.campaign)
      end
    end
  end
end
