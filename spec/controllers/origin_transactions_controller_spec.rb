require "rails_helper"

RSpec.describe OriginTransactionsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:origin_transaction, event_time: Time.current - 1.day) }
  end
  let(:tx) { OriginTransaction.first }

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:txs).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "PATCH update" do
    it "renders a successful response" do
      patch :update, params: { id: tx.id, origin_transaction: { campaign: 'test' } }

      expect(tx.reload.campaign).to eq('test')
      expect(response.code).to eq ('302')
    end
  end

  describe "GET users" do
    before { 10.times{ create(:origin_transaction, user_id: user.id) } }

    it "renders a successful response" do
      get :users

      expect(assigns(:txs).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:users)
    end
  end
end