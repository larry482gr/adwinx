require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  before(:each) do
    FactoryGirl.create(:language)
  end

  describe "GET /contacts" do
    it "responds with status 200 with valid user" do
      login_valid_user
      get contacts_path, { page: 1, limit: 50 }
      expect(response).to have_http_status(200)
    end

    it "responds with status 302 with invalid user" do
      get contacts_path
      expect(response).to have_http_status(302)
    end
  end
end
