require 'rails_helper'

RSpec.describe "contact_groups/edit", type: :view do
  create_english_lang
  login_user

  before(:each) do
    @contact_group = assign(:contact_group, ContactGroup.create!(
      :uid => 1,
      :label => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit contact_group form" do
    render

    assert_select "form[action=?][method=?]", contact_group_path(@contact_group), "post" do

      assert_select "input#contact_group_label[name=?]", "contact_group[label]"

      assert_select "input#contact_group_description[name=?]", "contact_group[description]"
    end
  end
end
