json.array!(@contacts) do |contact|
  json.extract! contact, :id, :prefix, :mobile, :contact_profile, :contact_groups
  # json.url contact_url(contact, format: :json)
end
