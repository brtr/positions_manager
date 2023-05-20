require "rails_helper"

RSpec.describe GetSpotBalanceHistoriesJob, type: :job do
  subject { described_class.new }

  describe '#GetSpotBalanceHistoriesJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetSpotBalanceHistoriesJob).on_queue('daily_job')
    end
  end
end
