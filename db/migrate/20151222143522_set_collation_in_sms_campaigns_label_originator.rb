class SetCollationInSmsCampaignsLabelOriginator < ActiveRecord::Migration
  def change
    change_column :sms_campaigns, :originator, 'VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :sms_campaigns, :label, 'VARCHAR(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
  end
end
