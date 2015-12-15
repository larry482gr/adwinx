class CreateSmsCampaignRecipients < ActiveRecord::Migration
  def change
    create_table :sms_campaigns_recipients do |t|
      t.references :sms_campaign
      t.text :contacts, { default: nil, comment: 'Array of phone numbers and/or contact ids' }
      t.text :contact_groups, { default: nil, comment: 'Array of contact_group ids' }
    end

    add_index :sms_campaigns_recipients, :sms_campaign_id, name: 'idx_sms_campaign_id'
    add_foreign_key :sms_campaigns_recipients, :sms_campaigns, column: :sms_campaign_id, primary_key: :id
  end
end
