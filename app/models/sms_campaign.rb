class SmsCampaign < ActiveRecord::Base
  belongs_to :user
  # belongs_to :account

  has_one :sms_recipient_list
  has_many :sms_restricted_time_ranges
  has_many :send_sms, :foreign_key => 'campaign_id', :class_name => 'SmsMessageSend'
  has_many :sent_sms, :foreign_key => 'campaign_id', :class_name => 'SmsMessageSent'

  validates :label, length: { maximum: 64 }
  validates :originator, presence: true, length: { maximum: 15 }
  validates :msg_body, presence: true

  accepts_nested_attributes_for :sms_recipient_list
  accepts_nested_attributes_for :sms_restricted_time_ranges

  private

  before_save :msg_url_encode

  def msg_url_encode
    self.msg_body = URI.encode(self.msg_body) unless self.msg_body.blank?
  end
end
