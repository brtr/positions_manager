require "rails_helper"

RSpec.describe GenerateUserSyncedPositionsSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GenerateUserSyncedPositionsSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GenerateUserSyncedPositionsSnapshotsJob).on_queue('daily_job')
    end

    it 'should generate snapshot info' do
      user = create(:user)
      create(:user_synced_position, user_id: user.id)

      expect do
        subject.perform
      end.to change { SnapshotInfo.count }.by(1)
    end
  end
end
