require "rails_helper"

RSpec.describe GetSyncedUserPositionsJob, type: :job do
  subject { described_class.new }

  describe '#GetSyncedUserPositionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetSyncedUserPositionsJob).on_queue('daily_job')
    end
  end
end
