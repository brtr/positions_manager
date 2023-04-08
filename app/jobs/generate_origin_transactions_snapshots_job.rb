class GenerateOriginTransactionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    # 查找或创建 TransactionsSnapshotInfo 记录
    transactions_snapshot_info = TransactionsSnapshotInfo.where(event_date: date).first_or_create

    # 生成快照记录
    generate_snapshot(transactions_snapshot_info)

    # 触发垃圾回收任务
    ForceGcJob.perform_later
  end

  private

  def generate_snapshot(transactions_snapshot_info)
    # 查找符合条件的原始交易记录
    origin_transactions = OriginTransaction.where(trade_type: 'buy')

    # 批量处理原始交易记录
    origin_transactions.find_each(batch_size: 100) do |origin_transaction|
      # 事务块内进行查询或创建快照记录
      transactions_snapshot_record = nil
      TransactionsSnapshotRecord.transaction do
        transactions_snapshot_record = transactions_snapshot_info.snapshot_records.find_or_initialize_by(
          order_id: origin_transaction.order_id,
          original_symbol: origin_transaction.original_symbol,
          trade_type: origin_transaction.trade_type,
          event_time: origin_transaction.event_time,
          source: origin_transaction.source
        )

        # 更新快照记录
        transactions_snapshot_record.update(
          from_symbol: origin_transaction.from_symbol,
          to_symbol: origin_transaction.to_symbol,
          fee_symbol: origin_transaction.fee_symbol,
          qty: origin_transaction.qty,
          price: origin_transaction.price,
          fee: origin_transaction.fee,
          amount: origin_transaction.amount,
          current_price: origin_transaction.current_price,
          revenue: origin_transaction.revenue,
          roi: origin_transaction.roi,
          campaign: origin_transaction.campaign
        )
      end
    end
  end
end
