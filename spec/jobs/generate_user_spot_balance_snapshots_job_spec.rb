require "rails_helper"

RSpec.describe GenerateUserSpotBalanceSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GenerateUserSpotBalanceSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GenerateUserSpotBalanceSnapshotsJob).on_queue('daily_job')
    end

    it 'should generate snapshot info' do
      user = create(:user)
      create(:user_spot_balance, user_id: user.id)

      expect do
        subject.perform
      end.to change { SpotBalanceSnapshotInfo.count }.by(1)
    end
  end
end
