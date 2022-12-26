require "rails_helper"

RSpec.describe GetSpotTransactionsJob, type: :job do
  subject { described_class.new }

  describe '#GetSpotTransactionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetSpotTransactionsJob).on_queue('daily_job')
    end
  end
end
