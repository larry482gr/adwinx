json.array!(@templates) do |template|
  json.extract! template, :id, :uid, :account_id, :label, :msg_body
  json.url template_url(template, format: :json)
end
