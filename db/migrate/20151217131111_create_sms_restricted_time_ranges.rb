class CreateSmsRestrictedTimeRanges < ActiveRecord::Migration
  def change
    create_table :sms_restricted_time_ranges do |t|
      t.references :sms_campaign, null: false
      t.time :start_time, { default: nil }
      t.time :end_time, { default: nil }
    end

    add_index :sms_restricted_time_ranges, :sms_campaign_id, name: 'idx_sms_restricted_time_ranges_campaign_id'
    add_foreign_key :sms_restricted_time_ranges, :sms_campaigns, column: :sms_campaign_id, primary_key: :id, on_delete: :cascade
  end
end
