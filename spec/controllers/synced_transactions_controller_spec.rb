require "rails_helper"

RSpec.describe SyncedTransactionsController, type: :controller do
  before do
    10.times{ create(:synced_transaction) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:txs).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "GET users" do
    let(:user) { create(:user) }
    before do
      sign_in user
      10.times{ create(:synced_transaction, user_id: user.id, event_time: Time.current - 1.day) }
    end

    it "renders a successful response" do
      get :users

      expect(assigns(:txs).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:users)
    end
  end
end