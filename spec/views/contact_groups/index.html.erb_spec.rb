require 'rails_helper'

RSpec.describe "contact_groups/index", type: :view do
  create_english_lang
  login_user

  before(:each) do
    ContactGroup.create!(
        :uid => controller.current_user.id,
        :label => "Label1",
        :description => "Description1"
    )
    ContactGroup.create!(
        :uid => controller.current_user.id,
        :label => "Label2",
        :description => "Description2"
    )

    contact_groups = ContactGroup.where(uid: controller.current_user.id)
                         .asc(:label)
                         .page(1).per(50)

    assign(:contact_groups, contact_groups)
  end

  it "renders a list of contact_groups" do
    render
    expect(rendered).to match(/Total contact groups: 2/)
    assert_select "tr>td", :text => "Label1", :count => 1
    assert_select "tr>td", :text => "Label2", :count => 1
    assert_select "tr>td", :text => "Description1", :count => 1
    assert_select "tr>td", :text => "Description2", :count => 1
  end
end
