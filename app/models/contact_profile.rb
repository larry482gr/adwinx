class ContactProfile
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :contact

  field :fn, as: :first_name, type: String
  field :ln, as: :last_name, type: String
end
