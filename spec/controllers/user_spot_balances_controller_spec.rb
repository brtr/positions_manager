require "rails_helper"

RSpec.describe UserSpotBalancesController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:user_spot_balance, user_id: user.id) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end
end