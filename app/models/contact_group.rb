class ContactGroup
  include Mongoid::Document
  field :uid, type: Integer
  field :label, type: String
  field :desc, type: String

  has_and_belongs_to_many :contacts

  validates :label, presence: true, length: { maximum: 20 }
  validates :description, length: { maximum: 127 }
end
