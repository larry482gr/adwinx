class Template
  include Mongoid::Document
  field :uid, type: Integer
  field :account_id, type: Integer
  field :label, type: String
  field :msg_body, type: String

  index({ uid: 1, label: 1 }, { name: 'uid_label_idx', unique: true, background: true })

  validates :uid, presence: true
  validates :label, presence: true, length: { maximum: 20 }
  validates :msg_body, presence: true

  # Clear blank (null, empty) fields before validation.
  include Cleanable

  # Set default pagination values.
  include Pageable
end
