require 'rails_helper'

RSpec.describe "contact_groups/show", type: :view do
  before(:each) do
    @contact_group = assign(:contact_group, ContactGroup.create!(
      :uid => 1,
      :label => "Label",
      :desc => "Desc"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/Desc/)
  end
end
