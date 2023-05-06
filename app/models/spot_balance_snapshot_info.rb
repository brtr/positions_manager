class SpotBalanceSnapshotInfo < ApplicationRecord
  has_many :spot_balance_snapshot_records, dependent: :destroy
  belongs_to :user, optional: true
end
