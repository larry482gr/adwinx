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

  before_save :set_dates_if_blank
  before_save :msg_url_encode
  after_find :msg_url_decode

  def set_dates_if_blank
    self.start_date = Time.now.to_i if self.start_date.blank?
    self.end_date = Time.now.end_of_day.to_i if self.end_date.blank?
  end

  def msg_url_encode
    self.msg_body = URI.encode(self.msg_body) unless self.msg_body.blank?
  end

  def msg_url_decode
    self.msg_body = URI.decode(self.msg_body) unless self.msg_body.blank?
  end
end
