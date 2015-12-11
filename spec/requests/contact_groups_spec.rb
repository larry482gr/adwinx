require 'rails_helper'

RSpec.describe "ContactGroups", type: :request do
  before(:each) do
    FactoryGirl.create(:language)
  end

  describe "GET /contact_groups" do
    it "responds with status 200 with valid user" do
      login_valid_user
      get contact_groups_path
      expect(response).to have_http_status(200)
    end

    it "responds with status 302 with invalid user" do
      get contact_groups_path
      expect(response).to have_http_status(302)
    end
  end
end
