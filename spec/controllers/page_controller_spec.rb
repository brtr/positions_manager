require "rails_helper"

RSpec.describe PageController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:user_position) }
  end

  describe "GET public user positions page" do
    it "renders a successful response" do
      get :user_positions

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:user_positions)
    end
  end

  describe "GET refresh user positions" do
    it "renders a successful response" do
      get :refresh_user_positions

      expect(response.code).to eq "302"
    end
  end

  describe "GET refresh 24hr ticker" do
    it "renders a successful response" do
      get :refresh_24hr_ticker

      expect(response.code).to eq "302"
    end
  end

  describe "GET recently adding positions" do
    it "renders a successful response" do
      get :recently_adding_positions

      expect(response).to be_successful
      expect(response).to render_template(:recently_adding_positions)
    end
  end

  describe "GET refresh recently adding positions" do
    it "renders a successful response" do
      get :refresh_recently_adding_positions

      expect(response.code).to eq "302"
    end
  end
end