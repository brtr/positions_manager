require "rails_helper"

RSpec.describe SyncPublicSpotBalancesJob, type: :job do
  subject { described_class.new }

  describe '#SyncPublicSpotBalancesJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(SyncPublicSpotBalancesJob).on_queue('daily_job')
    end
  end
end
