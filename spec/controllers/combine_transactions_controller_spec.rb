require "rails_helper"

RSpec.describe CombineTransactionsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:combine_transaction) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:txs).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end
end