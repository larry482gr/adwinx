class CreateSendSms < ActiveRecord::Migration
  def change
    create_table :send_sms, :id => false do |t|
      t.integer :id, limit: 8, null: false
      t.column :momt, "ENUM('MO', 'MT')"
      t.string :sender, limit: 20
      t.string :receiver, limit: 20
      t.binary :udhdata
      t.text :msgdata
      t.integer :time, limit: 8
      t.string :smsc_id
      t.string :service
      t.string :account
      t.integer :msg_id, limit: 8
      t.integer :sms_type, limit: 8
      t.integer :mclass, limit: 8
      t.integer :mwi, limit: 8
      t.integer :coding, limit: 8
      t.integer :compress, limit: 8
      t.integer :validity, limit: 8
      t.integer :deferred, limit: 8
      t.integer :dlr_mask, limit: 8
      t.string :dlr_url
      t.integer :pid, limit: 8
      t.integer :alt_dcs, limit: 8
      t.integer :rpi, limit: 8
      t.string :charset
      t.string :boxc_id
      t.string :binfo
      t.text :meta_data
      t.string :foreign_id
    end

    execute 'ALTER TABLE `send_sms` ADD PRIMARY KEY (`id`);'
    execute 'ALTER TABLE `send_sms` CHANGE `id` `id` BIGINT(20) NOT NULL AUTO_INCREMENT;'
  end
end
