require "rails_helper"

RSpec.describe GenerateUserPublicPositionsSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GenerateUserPublicPositionsSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GenerateUserPublicPositionsSnapshotsJob).on_queue('daily_job')
    end

    it 'should generate snapshot info' do
      create(:user_position)

      expect do
        subject.perform
      end.to change { SnapshotInfo.count }.by(1)
    end
  end
end
