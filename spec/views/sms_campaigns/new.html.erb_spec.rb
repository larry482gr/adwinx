require 'rails_helper'

RSpec.describe "sms_campaigns/new", type: :view do
  include SmsCampaignsHelper

  create_english_lang
  login_user

  before(:each) do
    @sms_campaign = SmsCampaign.new(
      :user => controller.current_user,
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
    )

    @sms_campaign.build_sms_recipient_list
    @sms_campaign.sms_restricted_time_ranges.build
    assign(:timezones, get_timezones)
  end

  it "renders new sms_campaign form" do
    render

    assert_select "form[action=?][method=?]", sms_campaigns_path, "post" do

      assert_select "input#sms_campaign_label[name=?]", "sms_campaign[label]"

      assert_select "input#sms_campaign_originator[name=?]", "sms_campaign[originator]"

      assert_select "select#sms_campaign_sms_recipient_list_attributes_contacts[name=?]",
                    "sms_campaign[sms_recipient_list_attributes][contacts][]"

      assert_select "select#sms_campaign_sms_recipient_list_attributes_contact_groups[name=?]",
                    "sms_campaign[sms_recipient_list_attributes][contact_groups][]"

      assert_select "textarea#sms_campaign_msg_body[name=?]", "sms_campaign[msg_body]"

      assert_select "input#sms_campaign_encoding[name=?]", "sms_campaign[encoding]"

      assert_select "input#sms_campaign_on_screen[name=?]", "sms_campaign[on_screen]"

    end
  end
end
