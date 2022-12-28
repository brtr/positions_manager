class TransactionsSnapshotInfo < ApplicationRecord
  has_many :snapshot_records, class_name: 'TransactionsSnapshotRecord', foreign_key: :transactions_snapshot_info_id
end
