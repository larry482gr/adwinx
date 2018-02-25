class SmsMessageSent < SmsMessage
  self.table_name = 'sent_sms'

  belongs_to :sms_campaign
end