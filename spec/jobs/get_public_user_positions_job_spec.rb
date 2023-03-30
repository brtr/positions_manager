require "rails_helper"

RSpec.describe GetPublicUserPositionsJob, type: :job do
  subject { described_class.new }

  describe '#GetPublicUserPositionsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GetPublicUserPositionsJob).on_queue('daily_job')
    end
  end
end
