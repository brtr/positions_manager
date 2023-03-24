require "rails_helper"

RSpec.describe GetSnapshotInfoSummaryJob, type: :job do
  subject { described_class.new }

  describe '#GetSnapshotInfoSummaryJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetSnapshotInfoSummaryJob).on_queue('default')
    end
  end
end
