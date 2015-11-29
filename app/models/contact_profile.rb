class ContactProfile
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :contact

  # Clear blank (null, empty) fields before validation.
  include Cleanable
end
