require 'rails_helper'

RSpec.describe "contact_groups/index", type: :view do
  before(:each) do
    assign(:contact_groups, [
      ContactGroup.create!(
        :uid => 1,
        :label => "Label",
        :desc => "Desc"
      ),
      ContactGroup.create!(
        :uid => 1,
        :label => "Label",
        :desc => "Desc"
      )
    ])
  end

  it "renders a list of contact_groups" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => "Desc".to_s, :count => 2
  end
end
