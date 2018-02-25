require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  create_english_lang
  login_user

  before(:each) do
    contact = Contact.new(uid: controller.current_user.id, prefix: 30, mobile: 1234567890)
    contact_profile = ContactProfile.new(first_name: 'Laz', last_name: 'Kaz')
    contact.contact_profile = contact_profile
    contact.save
    contact = Contact.new(uid: controller.current_user.id, prefix: 44, mobile: 1234567890)
    contact_profile = ContactProfile.new(first_name: 'Λαζάρ', last_name: 'Καζάν')
    contact.contact_profile = contact_profile
    contact.save
    contacts = Contact.includes(:contact_groups).where(uid: controller.current_user.id)
                   .asc('contact_profile.last_name').asc('contact_profile.first_name')
                   .page(1).per(50)
    assign(:contacts, contacts)
    assign(:metadata, controller.current_user.metadata)
    assign(:filters_form_action, '/contacts')
  end

  it "renders a list of contacts" do
    render
    expect(rendered).to match(/Total contacts: 2/)
    assert_select "tr>td", :text => 30.to_s, :count => 1
    assert_select "tr>td", :text => 44.to_s, :count => 1
    assert_select "tr>td", :text => 1234567890.to_s, :count => 2
    assert_select "tr>td", :text => 'Laz', :count => 1
    assert_select "tr>td", :text => 'Kaz', :count => 1
    assert_select "tr>td", :text => 'Λαζάρ', :count => 1
    assert_select "tr>td", :text => 'Καζάν', :count => 1
  end
end
