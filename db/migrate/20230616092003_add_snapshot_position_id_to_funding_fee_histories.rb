class AddSnapshotPositionIdToFundingFeeHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :funding_fee_histories, :snapshot_position_id, :integer
  end
end
