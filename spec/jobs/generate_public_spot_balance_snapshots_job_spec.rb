require "rails_helper"

RSpec.describe GeneratePublicSpotBalanceSnapshotsJob, type: :job do
  subject { described_class.new }

  describe '#GeneratePublicSpotBalanceSnapshotsJob perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'should enqeue job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(GeneratePublicSpotBalanceSnapshotsJob).on_queue('daily_job')
    end

    it 'should generate snapshot info' do
      create(:user_spot_balance)

      expect do
        subject.perform
      end.to change { SpotBalanceSnapshotInfo.count }.by(1)
    end
  end
end
