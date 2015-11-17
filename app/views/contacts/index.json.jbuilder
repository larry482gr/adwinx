json.array!(@contacts) do |contact|
  json.extract! contact, :id, :uid, :prefix, :mobile
  json.url contact_url(contact, format: :json)
end
