class SmsCampaign < ActiveRecord::Base
  belongs_to :user
  # belongs_to :account

  has_many :sms_campaign_recipients

  validates :label, length: { maximum: 64 }
  validates :originator, length: { maximum: 15 }
end
