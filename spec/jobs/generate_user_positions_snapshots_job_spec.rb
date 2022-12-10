require "rails_helper"

RSpec.describe GenerateUserPositionsSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GenerateUserPositionsSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GenerateUserPositionsSnapshotsJob).on_queue('daily_job')
    end
  end
end
