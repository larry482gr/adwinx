require 'rails_helper'

RSpec.describe "contact_groups/show", type: :view do
  create_english_lang
  login_user

  before(:each) do
    @contact_group = assign(:contact_group, ContactGroup.create!(
      :uid => 1,
      :label => "bwrjhnbvi",
      :description => "fhbvwue vwbweu vbweu vwe vweuburbvwe"
    ))

    contact1 = Contact.new(uid: 1, prefix: 30, mobile: 1234567890)
    contact_profile = ContactProfile.new(first_name: 'Laz', last_name: 'Kaz')
    contact1.contact_profile = contact_profile
    contact1[:contact_group_ids] = [@contact_group[:_id]]
    contact1.save
    contact2 = Contact.new(uid: 1, prefix: 30, mobile: 9876543210)
    contact_profile = ContactProfile.new(first_name: 'Λαζάρ', last_name: 'Καζάν')
    contact2.contact_profile = contact_profile
    contact2[:contact_group_ids] = []
    contact2.save

    contacts = Contact.includes(:contact_groups).where(:_id => { '$in' => [contact1] })
                    .asc('contact_profile.last_name').asc('contact_profile.first_name')
                    .page(params[:page]).per(params[:limit])

    assign(:contacts, contacts)
    assign(:metadata, controller.current_user.metadata)
    assign(:filters_form_action, '/contact_groups')
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Total contacts: 1/)
    expect(rendered).to match(/bwrjhnbvi/)
    expect(rendered).to match(/fhbvwue vwbweu vbweu vwe vweuburbvwe/)
    expect(rendered).to match(/30/)
    expect(rendered).to match(/1234567890/)
    expect(rendered).not_to match(/9876543210/)
  end
end
