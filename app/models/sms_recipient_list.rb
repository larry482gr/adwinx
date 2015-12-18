class SmsRecipientList < ActiveRecord::Base
  belongs_to :sms_campaign, touch: true

  serialize :contacts, JSON
  serialize :contact_groups, JSON

  private

  before_save :reject_blank

  def reject_blank
    self.contacts = self.contacts.reject { |contact| contact.blank? }
    self.contact_groups = self.contact_groups.reject { |contact_group| contact_group.blank? }
  end
end
