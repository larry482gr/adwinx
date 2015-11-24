class ContactGroup
  include Mongoid::Document
  field :uid, type: Integer
  field :label, type: String
  field :description, type: String

  index({ uid: 1, label: 1 }, { name: 'uid_label_idx', unique: true, background: true })

  has_and_belongs_to_many :contacts, inverse_of: nil

  validates :uid, presence: true
  validates :label, presence: true, length: { maximum: 20 }
  validates :description, length: { maximum: 120 }

  # Clear blank (null, empty) fields before validation.
  include Cleanable

  # Set default pagination values.
  include Pageable
end
