require "rails_helper"

RSpec.describe GetRecentlyAddingPositionsJob, type: :job do
  subject { described_class.new }

  describe '#GetRecentlyAddingPositionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetRecentlyAddingPositionsJob).on_queue('daily_job')
    end

    it 'should get adding positions history' do
      tx = create(:synced_transaction, origin_symbol: 'BTCUSDT', event_time: Date.yesterday)

      expect do
        subject.perform
      end.to change { AddingPositionsHistory.count }.by(1)
    end
  end
end
