require "rails_helper"

RSpec.describe UserPositionsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    10.times{ create(:user_position, user_id: user.id) }
  end

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "Post #import_csv" do
    it "should redirect with alert" do
      post :import_csv
      expect(flash[:alert]).to eq("请选择文件")
      expect(response).to redirect_to user_positions_path
    end

    it "should upload success" do
      temple_file = fixture_file_upload("public/samples/Import_template.csv", ".csv")

      post :import_csv, params: { file: temple_file, source: 'binance' }
      expect(flash[:notice]).to include("成功导入")
      expect(response).to redirect_to user_positions_path
    end

    it "upload fail exclude csv xlsx" do
      temple_file = fixture_file_upload("public/404.html", ".html")

      post :import_csv, params: { file: temple_file, source: 'binance' }
      expect(flash[:alert]).to include("仅支持csv 和 xlxs")
      expect(response).to redirect_to user_positions_path
    end
  end
end