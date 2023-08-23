namespace :data do
  desc "Update adding positions histories' event date"
  task update_adding_positions_histories_event_date: :environment do
    days_to_subtract = 1
    AddingPositionsHistory.update_all("event_date = event_date - INTERVAL '#{days_to_subtract} days'")
  end
end