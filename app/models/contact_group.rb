class ContactGroup
  include Mongoid::Document
  field :label, type: String
  field :description, type: String

  has_and_belongs_to_many :contacts

  validates :label, presence: true, length: { maximum: 20 }
  validates :description, length: { maximum: 127 }
end
