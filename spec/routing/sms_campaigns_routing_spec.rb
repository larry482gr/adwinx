require "rails_helper"

RSpec.describe SmsCampaignsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      # expect(:get => "/sms_campaigns").to route_to("sms_campaigns#index")
    end

    it "routes to #new" do
      # expect(:get => "/sms_campaigns/new").to route_to("sms_campaigns#new")
    end

    it "routes to #show" do
      # expect(:get => "/sms_campaigns/1").to route_to("sms_campaigns#show", :id => "1")
    end

    it "routes to #edit" do
      # expect(:get => "/sms_campaigns/1/edit").to route_to("sms_campaigns#edit", :id => "1")
    end

    it "routes to #create" do
      # expect(:post => "/sms_campaigns").to route_to("sms_campaigns#create")
    end

    it "routes to #update via PUT" do
      # expect(:put => "/sms_campaigns/1").to route_to("sms_campaigns#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      # expect(:patch => "/sms_campaigns/1").to route_to("sms_campaigns#update", :id => "1")
    end

    it "routes to #destroy" do
      # expect(:delete => "/sms_campaigns/1").to route_to("sms_campaigns#destroy", :id => "1")
    end

  end
end
