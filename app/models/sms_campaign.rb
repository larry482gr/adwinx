class SmsCampaign < ActiveRecord::Base
  belongs_to :user
  # belongs_to :account

  has_one :sms_recipient_list

  validates :label, length: { maximum: 64 }
  validates :originator, length: { maximum: 15 }

  accepts_nested_attributes_for :sms_recipient_list
end
