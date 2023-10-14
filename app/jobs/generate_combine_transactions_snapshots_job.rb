class GenerateCombineTransactionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    transactions_snapshot_info = CombineTxSnapshotInfo.where(event_date: date).first_or_create

    generate_snapshot(transactions_snapshot_info)

    ForceGcJob.perform_later
  end

  private

  def generate_snapshot(transactions_snapshot_info)
    txs = CombineTransaction.all

    txs.find_each(batch_size: 100) do |tx|
      CombineTxSnapshotInfo.transaction do
        transactions_snapshot_record = transactions_snapshot_info.combine_tx_snapshot_records.find_or_initialize_by(
          original_symbol: tx.original_symbol,
          trade_type: tx.trade_type,
          source: tx.source,
          from_symbol: tx.from_symbol,
          to_symbol: tx.to_symbol,
          fee_symbol: tx.fee_symbol
        )

        # 更新快照记录
        transactions_snapshot_record.update(
          qty: tx.qty,
          price: tx.price,
          fee: tx.fee,
          amount: tx.amount,
          current_price: tx.current_price,
          revenue: tx.revenue,
          roi: tx.roi
        )
      end
    end
  end
end
