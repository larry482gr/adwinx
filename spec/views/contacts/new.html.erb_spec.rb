require 'rails_helper'

RSpec.describe "contacts/new", type: :view do
  create_english_lang
  login_user

  before(:each) do
    @contact = Contact.new(:uid => 1, :prefix => 30, :mobile => 1234567890)
    contact_profile = ContactProfile.new(first_name: 'Laz', last_name: 'Kaz')
    @contact.contact_profile = contact_profile
    assign(:contact, @contact)
  end

  it "renders new contact form" do
    render

    assert_select "form[action=?][method=?]", contacts_path, "post" do

      assert_select "input#contact_prefix[name=?]", "contact[prefix]"

      assert_select "input#contact_mobile[name=?]", "contact[mobile]"

      assert_select "input#contact_contact_profile_attributes_first_name[name=?]", "contact[contact_profile_attributes][first_name]"

      assert_select "input#contact_contact_profile_attributes_last_name[name=?]", "contact[contact_profile_attributes][last_name]"

    end
  end
end
