class SmsMessageSend < SmsMessage
  self.table_name = 'send_sms'

  belongs_to :sms_campaign
end