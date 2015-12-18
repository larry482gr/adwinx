class CreateSmsRecipientLists < ActiveRecord::Migration
  def change
    create_table :sms_recipient_lists, id: false do |t|
      t.references :sms_campaign, { null: false }
      t.text :contacts, { default: nil, comment: 'Array of phone numbers and/or contact ids' }
      t.text :contact_groups, { default: nil, comment: 'Array of contact_group ids' }
    end

    add_index :sms_recipient_lists, :sms_campaign_id, name: 'idx_sms_campaign_id'
    add_foreign_key :sms_recipient_lists, :sms_campaigns, column: :sms_campaign_id, primary_key: :id, on_delete: :cascade
  end
end
