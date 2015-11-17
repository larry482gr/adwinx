require 'rails_helper'

RSpec.describe "contacts/new", type: :view do
  before(:each) do
    assign(:contact, Contact.new(
      :uid => 1,
      :prefix => 1,
      :mobile => 1
    ))
  end

  it "renders new contact form" do
    render

    assert_select "form[action=?][method=?]", contacts_path, "post" do

      assert_select "input#contact_uid[name=?]", "contact[uid]"

      assert_select "input#contact_prefix[name=?]", "contact[prefix]"

      assert_select "input#contact_mobile[name=?]", "contact[mobile]"
    end
  end
end
