class AddCampaignIdToSqlboxSendSms < ActiveRecord::Migration
  def change
    add_column :send_sms, :campaign_id, :integer, limit: 8
  end
end
