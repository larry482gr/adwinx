class Contact
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :prefix, type: Integer
  field :mobile, type: Integer

  embeds_one :contact_profile
  has_and_belongs_to_many :contact_groups

  validates :prefix, presence: true, length: { maximum: 4 }
  validates :mobile, presence: true, length: { minimum: 6, maximum: 16 }

  accepts_nested_attributes_for :contact_profile, :contact_groups
end
