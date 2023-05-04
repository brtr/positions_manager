class SpotBalanceSnapshotRecord < ApplicationRecord
  belongs_to :spot_balance_snapshot_info

  def current_price
    OriginTransaction.find_by(original_symbol: origin_symbol, source: source)&.current_price
  end
end
