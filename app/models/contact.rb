class Contact
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :uid, type: Integer
  field :prefix, type: Integer
  field :mobile, type: Integer

  index({ uid: 1 }, { name: 'uid_idx', background: true })
  index({ uid: 1, prefix: 1, mobile: 1 }, { name: 'uid_prefix_mobile_idx', unique: true, background: true })

  embeds_one :contact_profile
  has_and_belongs_to_many :contact_groups

  validates :prefix, presence: true, length: { maximum: 4 }
  validates :mobile, presence: true, length: { minimum: 6, maximum: 16 }

  accepts_nested_attributes_for :contact_profile, :contact_groups
end
