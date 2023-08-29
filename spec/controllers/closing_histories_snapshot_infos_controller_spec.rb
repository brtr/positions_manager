require "rails_helper"

RSpec.describe ClosingHistoriesSnapshotInfosController, type: :controller do
  let(:snapshot_info) { create(:closing_histories_snapshot_info) }
  before do
    10.times{ create(:closing_histories_snapshot_record, closing_histories_snapshot_info: snapshot_info) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(response).to be_successful
      expect(response).to render_template(:index)
      expect(assigns(:results).first[:monthes].first[:dates].size).to eq 1
    end
  end

  describe "GET show" do
    it "renders a successful response" do
      get :show, params: { id: snapshot_info.id }

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end
end