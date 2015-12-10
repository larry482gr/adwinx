class AddMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :metadata, :text, null: false, default: '[first_name, last_name]'
  end
end
