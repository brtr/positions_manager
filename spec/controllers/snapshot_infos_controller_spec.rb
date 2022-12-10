require "rails_helper"

RSpec.describe SnapshotInfosController, type: :controller do
  let(:snapshot_info) { create(:snapshot_info) }
  before do
    10.times{ create(:snapshot_position, snapshot_info: snapshot_info) }
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

      expect(assigns(:records).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  describe "GET positions_graphs" do
    it "renders a successful response" do
      get :positions_graphs

      expect(response).to be_successful
    end
  end

  describe "GET export_roi" do
    it "generate CSV" do
      get :export_roi, format: :csv

      expect(response.header['Content-Type']).to include 'text/csv'
    end
  end
end