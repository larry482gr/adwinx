json.array!(@sms_campaigns) do |sms_campaign|
  json.extract! sms_campaign, :id, :user_id, :account_id, :label, :originator, :msg_body, :start_date, :end_date, :restriction_start_date, :restriction_end_date, :encoding, :on_screen, :total_sms, :sent_to_box, :finished, :state, :estimated_cost
  json.url sms_campaign_url(sms_campaign, format: :json)
end
