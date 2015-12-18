require 'rails_helper'

RSpec.describe "sms_campaigns/index", type: :view do
  create_english_lang
  login_user

  before(:each) do
    assign(:sms_campaigns, [
      SmsCampaign.create!(
        :user => controller.current_user,
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
      ),
      SmsCampaign.create!(
        :user => controller.current_user,
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
      )
    ])
  end

  it "renders a list of sms_campaigns" do
    render
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => "Originator".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
