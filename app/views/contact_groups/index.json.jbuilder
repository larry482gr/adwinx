json.array!(@contact_groups) do |contact_group|
  json.extract! contact_group, :id, :label, :description
  json.url contact_group_url(contact_group, format: :json)
end
