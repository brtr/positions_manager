require "rails_helper"

RSpec.describe WalletHistoriesController, type: :controller do
  before do
    10.times{ create(:wallet_history) }
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