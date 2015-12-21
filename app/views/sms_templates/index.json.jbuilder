json.array!(@sms_templates) do |sms_template|
  json.extract! sms_template, :id, :uid, :account_id, :label, :msg_body
  json.url sms_template_url(sms_template, format: :json)
end
