require "rails_helper"

RSpec.describe RankingSnapshotsController, type: :controller do
  before do
    create_list(:ranking_snapshot, 5)
    create_list(:ranking_snapshot, 5, event_date: Date.today - 2.days)
    create_list(:ranking_snapshot, 5, event_date: Date.today - 5.days)
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(response).to be_successful
      expect(response).to render_template(:index)
      expect(assigns(:three_days_ranking).size).to eq 10
      expect(assigns(:weekly_ranking).size).to eq 15
    end
  end
end