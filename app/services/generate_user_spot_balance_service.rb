class GenerateUserSpotBalanceService
  class << self
    def execute(user_id: nil)
      UserSpotBalance.transaction do
        snapshots = SpotBalanceSnapshotRecord.joins(:spot_balance_snapshot_info).where(spot_balance_snapshot_info: {user_id: user_id, event_date: Date.today})
        snapshots.each do |snapshot|
          usb = UserSpotBalance.where(user_id: user_id, origin_symbol: snapshot.origin_symbol, source: snapshot.source).first_or_initialize
          usb.update(
            from_symbol: snapshot.from_symbol,
            to_symbol: snapshot.to_symbol,
            price: snapshot.price,
            qty: snapshot.qty,
            amount: snapshot.amount
          )
        end
      end
    end
  end
end