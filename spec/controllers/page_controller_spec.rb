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
end