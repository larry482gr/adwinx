class CreateSmsRecipientLists < ActiveRecord::Migration
  def change
    create_table :sms_recipient_lists do |t|
      t.references :sms_campaign
      t.text :contacts, { default: nil, comment: 'Array of phone numbers and/or contact ids' }
      t.text :contact_groups, { default: nil, comment: 'Array of contact_group ids' }
    end

    add_index :sms_recipient_lists, :sms_campaign_id, name: 'idx_sms_campaign_id'
    add_foreign_key :sms_recipient_lists, :sms_campaigns, column: :sms_campaign_id, primary_key: :id
  end
end
