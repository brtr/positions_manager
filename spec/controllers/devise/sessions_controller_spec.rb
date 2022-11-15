require "rails_helper"

RSpec.describe Devise::SessionsController do
  describe "GET index" do

    it "get sign_in success" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get :new
      expect(response).to be_successful
    end
  end
end