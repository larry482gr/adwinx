class SmsRestrictedTimeRange < ActiveRecord::Base
  belongs_to :sms_campaign, touch: true
end
