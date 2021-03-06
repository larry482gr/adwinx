class Contact
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :uid, type: Integer
  field :prefix, type: String
  field :mobile, type: String

  index({ uid: 1 }, { name: 'uid_idx', background: true })
  index({ uid: 1, prefix: 1, mobile: 1 }, { name: 'uid_prefix_mobile_idx', unique: true, background: true })
  index({ uid: 1, 'contact_profile.first_name': 1}, { name: 'first_name_idx', background: true, sparse: true })
  index({ uid: 1, 'contact_profile.last_name': 1}, { name: 'last_name_idx', background: true, sparse: true })
  index({ uid: 1, contact_group_ids: 1 }, { name: 'contact_group_ids_idx', background: true })

  embeds_one :contact_profile, cascade_callbacks: true
  has_and_belongs_to_many :contact_groups, inverse_of: nil

  validates :uid, presence: true
  validates :prefix, presence: true, length: { maximum: 4 }
  validates :mobile, presence: true, length: { minimum: 6, maximum: 16 }

  accepts_nested_attributes_for :contact_profile

  # Set default pagination values.
  include Pageable
end
