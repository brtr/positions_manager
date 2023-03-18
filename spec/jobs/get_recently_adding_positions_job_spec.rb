require "rails_helper"

RSpec.describe GetRecentlyAddingPositionsJob, type: :job do
  subject { described_class.new }

  describe '#GetRecentlyAddingPositionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetRecentlyAddingPositionsJob).on_queue('daily_job')
    end
  end
end
