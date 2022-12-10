require "rails_helper"

RSpec.describe UserSyncedPositionsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:user_synced_position, user_id: user.id) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "#POST add_key" do
    it "should alert without api_key" do
      post :add_key, params: { secret_key: '123' }

      expect(flash[:alert]).to have_content('API KEY / SECRET KEY 不能为空')
    end

    it "should alert with invalid key" do
      post :add_key, params: { api_key: '123', secret_key: '123' }

      expect(flash[:alert]).to have_content('币安API KEY绑定失败，请检查后重试')
    end
  end

  describe "#GET refresh" do
    it "should alert without api_key" do
      get :refresh

      expect(flash[:alert]).to have_content('请绑定API KEY后再尝试刷新仓位')
    end
  end
end