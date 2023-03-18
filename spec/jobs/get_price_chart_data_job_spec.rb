require "rails_helper"

RSpec.describe GetPriceChartDataJob, type: :job do
  subject { described_class.new }

  describe '#GetPriceChartDataJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetPriceChartDataJob).on_queue('daily_job')
    end
  end
end
