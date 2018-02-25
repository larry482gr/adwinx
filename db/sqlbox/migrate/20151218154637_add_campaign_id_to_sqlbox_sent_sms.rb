class AddCampaignIdToSqlboxSentSms < ActiveRecord::Migration
  def change
    add_column :sent_sms, :campaign_id, :integer, limit: 8
  end
end
