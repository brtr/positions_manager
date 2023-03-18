require "rails_helper"

RSpec.describe GetBinanceFuturesTransactionsJob, type: :job do
  subject { described_class.new }

  describe '#GetBinanceFuturesTransactionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetBinanceFuturesTransactionsJob).on_queue('daily_job')
    end
  end
end
