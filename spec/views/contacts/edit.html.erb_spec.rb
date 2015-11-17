require 'rails_helper'

RSpec.describe "contacts/edit", type: :view do
  before(:each) do
    @contact = assign(:contact, Contact.create!(
      :uid => 1,
      :prefix => 1,
      :mobile => 1
    ))
  end

  it "renders the edit contact form" do
    render

    assert_select "form[action=?][method=?]", contact_path(@contact), "post" do

      assert_select "input#contact_uid[name=?]", "contact[uid]"

      assert_select "input#contact_prefix[name=?]", "contact[prefix]"

      assert_select "input#contact_mobile[name=?]", "contact[mobile]"
    end
  end
end
