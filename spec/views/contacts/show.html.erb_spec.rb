require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  create_english_lang
  login_user

  before(:each) do
    @contact = Contact.new(:uid => 1, :prefix => 30, :mobile => 1234567890)
    contact_profile = ContactProfile.new(first_name: 'Laz', last_name: 'Kaz')
    @contact.contact_profile = contact_profile
    @contact.save
    assign(:contact, @contact)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/30/)
    expect(rendered).to match(/1234567890/)
    expect(rendered).to match(/Laz/)
    expect(rendered).to match(/Kaz/)
  end
end
