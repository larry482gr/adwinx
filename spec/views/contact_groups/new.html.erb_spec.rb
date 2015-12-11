require 'rails_helper'

RSpec.describe "contact_groups/new", type: :view do
  create_english_lang
  login_user

  before(:each) do
    assign(:contact_group, ContactGroup.new(
      :uid => 1,
      :label => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new contact_group form" do
    render

    assert_select "form[action=?][method=?]", contact_groups_path, "post" do

      assert_select "input#contact_group_label[name=?]", "contact_group[label]"

      assert_select "input#contact_group_description[name=?]", "contact_group[description]"
    end
  end
end
