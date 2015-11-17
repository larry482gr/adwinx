require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      Contact.create!(
        :uid => 1,
        :prefix => 2,
        :mobile => 3
      ),
      Contact.create!(
        :uid => 1,
        :prefix => 2,
        :mobile => 3
      )
    ])
  end

  it "renders a list of contacts" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
