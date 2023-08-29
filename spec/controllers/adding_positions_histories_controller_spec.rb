require "rails_helper"

RSpec.describe AddingPositionsHistoriesController, type: :controller do
  before do
    10.times{ create(:adding_positions_history, qty: -123) }
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