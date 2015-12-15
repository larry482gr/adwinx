require 'rails_helper'

RSpec.describe "sms_campaigns/show", type: :view do
  before(:each) do
    @sms_campaign = assign(:sms_campaign, SmsCampaign.create!(
      :user => nil,
      :account_id => nil,
      :label => "Label",
      :originator => "Originator",
      :msg_body => "MyText",
      :encoding => 1,
      :on_screen => 2,
      :total_sms => 3,
      :sent_to_box => 4,
      :finished => false,
      :state => 5,
      :estimated_cost => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/Originator/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(//)
  end
end
