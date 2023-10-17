require "rails_helper"

RSpec.describe GenerateCombineTransactionsSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GenerateCombineTransactionsSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GenerateCombineTransactionsSnapshotsJob).on_queue('daily_job')
    end
  end
end
