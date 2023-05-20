require "rails_helper"

RSpec.describe GetFundingFeeHistoriesJob, type: :job do
  subject { described_class.new }

  describe '#GetFundingFeeHistoriesJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetFundingFeeHistoriesJob).on_queue('daily_job')
    end
  end
end
