require 'rails_helper'

RSpec.describe "contact_groups/index", type: :view do
  before(:each) do
    assign(:contact_groups, [
      ContactGroup.create!(
        :label => "Label",
        :description => "Description"
      ),
      ContactGroup.create!(
        :label => "Label",
        :description => "Description"
      )
    ])
  end

  it "renders a list of contact_groups" do
    render
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
