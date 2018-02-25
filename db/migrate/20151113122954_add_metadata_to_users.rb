class AddMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :metadata, :text
    change_column :users, :metadata, 'TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci'
  end
end
