require 'rails_helper'

RSpec.describe "sms_campaigns/new", type: :view do
  before(:each) do
    assign(:sms_campaign, SmsCampaign.new(
      :user => nil,
      :account_id => nil,
      :label => "MyString",
      :originator => "MyString",
      :msg_body => "MyText",
      :encoding => 1,
      :on_screen => 1,
      :total_sms => 1,
      :sent_to_box => 1,
      :finished => false,
      :state => 1,
      :estimated_cost => ""
    ))
  end

  it "renders new sms_campaign form" do
    render

    assert_select "form[action=?][method=?]", sms_campaigns_path, "post" do

      assert_select "input#sms_campaign_user_id[name=?]", "sms_campaign[user_id]"

      assert_select "input#sms_campaign_account_id[name=?]", "sms_campaign[account_id]"

      assert_select "input#sms_campaign_label[name=?]", "sms_campaign[label]"

      assert_select "input#sms_campaign_originator[name=?]", "sms_campaign[originator]"

      assert_select "textarea#sms_campaign_msg_body[name=?]", "sms_campaign[msg_body]"

      assert_select "input#sms_campaign_encoding[name=?]", "sms_campaign[encoding]"

      assert_select "input#sms_campaign_on_screen[name=?]", "sms_campaign[on_screen]"

      assert_select "input#sms_campaign_total_sms[name=?]", "sms_campaign[total_sms]"

      assert_select "input#sms_campaign_sent_to_box[name=?]", "sms_campaign[sent_to_box]"

      assert_select "input#sms_campaign_finished[name=?]", "sms_campaign[finished]"

      assert_select "input#sms_campaign_state[name=?]", "sms_campaign[state]"

      assert_select "input#sms_campaign_estimated_cost[name=?]", "sms_campaign[estimated_cost]"
    end
  end
end
