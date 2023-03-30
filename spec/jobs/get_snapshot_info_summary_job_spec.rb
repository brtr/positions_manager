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

    it 'should update snapshot info' do
      info = create(:snapshot_info)
      subject.perform(info, info.event_date, true)

      expect(info.reload.increase_count).to eq(0)
      expect(info.reload.decrease_count).to eq(0)
      expect(info.reload.btc_change).to be_nil
    end
  end
end
