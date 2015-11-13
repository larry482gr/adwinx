require 'rails_helper'

RSpec.describe "contacts/edit", type: :view do
  before(:each) do
    @contact = assign(:contact, Contact.create!(
      :prefix => 30,
      :mobile => 6945274744
    ))
  end

  it "renders the edit contact form" do
    render

    assert_select "form[action=?][method=?]", contact_path(@contact), "post" do

      assert_select "input#contact_prefix[name=?]", "contact[prefix]"

      assert_select "input#contact_mobile[name=?]", "contact[mobile]"
    end
  end
end
