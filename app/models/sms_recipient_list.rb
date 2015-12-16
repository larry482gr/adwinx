class SmsRecipientList < ActiveRecord::Base
  belongs_to :sms_campaign, touch: true

  serialize :contacts, JSON
  serialize :contact_groups, JSON
end
