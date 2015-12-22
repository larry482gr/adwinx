module SmsCampaignsHelper
  def get_timezones
    timezones = []

    TZInfo::Timezone.all_data_zones.each do |tz|
      next if ['Etc - ', 'GMT'].any? { |zone| tz.friendly_identifier.include? zone }
      total_offset = tz.current_period.utc_total_offset
      hours   = sprintf("%+03d", total_offset/3600)
      minutes = sprintf("%02d", (total_offset % 3600)/60)
      utc_offset = total_offset >= 0 ?
          "#{hours}:#{minutes}" :
          "#{hours}:#{minutes}"

      timezones << { canonical: tz.canonical_identifier,
                     friendly: tz.friendly_identifier,
                     utc_offset: utc_offset }


        # puts "\n\n==============================\n\n"
        # puts tz.canonical_identifier
        # puts tz.friendly_identifier
        # current = tz.current_period
        # puts current.dst?
        # puts current.utc_offset
        # puts current.std_offset
        # puts current.utc_total_offset
        # puts "\n\n==============================\n\n"
    end

    return timezones
  end

  class << self
    def write_messages user_id, campaign_id
      campaign  = SmsCampaign.find(campaign_id)
      phones    = campaign.sms_recipient_list.contacts

      group_phones  = groups_contacts(user_id, campaign.sms_recipient_list.contact_groups)
      (phones << group_phones).flatten!.uniq!

      sms = []

      # TODO ===== ATTENTION ===== Check message parameters before going to production!!!
      phones.each do |phone|
        sms << campaign.send_sms.new(momt: 'MT', sender: campaign.originator, receiver: phone,
                                     msgdata: campaign.msg_body, time: campaign.start_date,
                                     smsc_id: 'fakesmsc1', sms_type: 2, mclass: campaign.on_screen,
                                     coding: campaign.encoding, dlr_mask: 31)
      end

      SmsMessageSend.import sms
    end
    handle_asynchronously :write_messages

    def groups_contacts(user_id, groups)
      # phones = []
      contacts = Contact.where(uid: user_id, contact_group_ids: { '$in' => groups }).pluck(:prefix, :mobile)

      phones = contacts.collect { |contact| contact.join() }

      return phones
    end
  end
end
