class SnapshotInfo < ApplicationRecord
  has_many :snapshot_positions, dependent: :destroy
  belongs_to :user
end
