require "rails_helper"

RSpec.describe ContactGroupsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/contact_groups").to route_to("contact_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/contact_groups/new").to route_to("contact_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/contact_groups/1").to route_to("contact_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/contact_groups/1/edit").to route_to("contact_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/contact_groups").to route_to("contact_groups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/contact_groups/1").to route_to("contact_groups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/contact_groups/1").to route_to("contact_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/contact_groups/1").to route_to("contact_groups#destroy", :id => "1")
    end

  end
end
