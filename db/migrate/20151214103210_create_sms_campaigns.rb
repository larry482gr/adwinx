class CreateSmsCampaigns < ActiveRecord::Migration
  def change
    create_table :sms_campaigns do |t|
      t.references :user
      t.integer :account_id
      # t.references :account
      t.string :label, { limit:64, default: nil }
      t.string :originator, { limit: 20, default: nil }
      t.text :msg_body, { default: nil }
      t.integer :start_date, { limit: 8, default: nil }
      t.integer :end_date, { limit: 8, default: nil }
      t.integer :restriction_start_date, { limit: 8, default: nil }
      t.integer :restriction_end_date, { limit: 8, default: nil }
      t.integer :encoding, { limit: 8, default: nil }
      t.integer :on_screen, { limit: 8, default: nil }
      t.integer :total_sms, { limit: 8, default: nil }
      t.integer :sent_to_box, { limit: 8, default: nil }
      t.boolean :finished, { default: false }
      t.integer :state, { limit: 1, default: 0, comment: '0: scheduled, 1: started, 2: paused, 3: stopped, 4: archieved' }
      t.decimal :estimated_cost, { default: nil, precision: 10, scale: 5 }

      t.timestamps null: false
    end

    change_column :sms_campaigns, :originator, 'VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci'
    change_column :sms_campaigns, :label, 'VARCHAR(64) CHARACTER SET utf8 COLLATE utf8_unicode_ci'

  end
end
