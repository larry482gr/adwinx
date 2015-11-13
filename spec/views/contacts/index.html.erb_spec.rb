require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      Contact.create!(
        :prefix => 30,
        :mobile => 6945274744
      ),
      Contact.create!(
        :prefix => 1,
        :mobile => 1686484554
      )
    ])
  end

  it "renders a list of contacts" do
    render
    assert_select "tr>td", :text => 30.to_s, :count => 1
    assert_select "tr>td", :text => 6945274744.to_s, :count => 1
    assert_select "tr>td", :text => 1.to_s, :count => 1
    assert_select "tr>td", :text => 1686484554.to_s, :count => 1
  end
end
