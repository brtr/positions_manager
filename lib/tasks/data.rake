namespace :data do
  desc "Update adding positions histories' event date"
  task update_adding_positions_histories_event_date: :environment do
    days_to_subtract = 1
    AddingPositionsHistory.update_all("event_date = event_date - INTERVAL '#{days_to_subtract} days'")
  end

  desc "Update adding positions histories' trading roi"
  task update_adding_positions_histories_trading_roi: :environment do
    up_roi_by_date = {}

    # 查询所有满足条件的 SnapshotPosition 并存储在 up_roi_by_date 中
    SnapshotPosition.includes(:snapshot_info).joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil}).find_each do |up|
      up_date = up.snapshot_info.event_date
      up_roi_by_date[up_date] ||= {}
      up_roi_by_date[up_date][[up.origin_symbol, up.trade_type, up.source]] = up.roi if up.roi.present?
    end

    # 批量更新 AddingPositionsHistory
    AddingPositionsHistory.find_each do |aph|
      up_roi = up_roi_by_date[aph.event_date][[aph.origin_symbol, aph.trade_type, aph.source]] rescue nil

      if up_roi.present?
        aph.update(trading_roi: up_roi)
      end
    end
  end
end