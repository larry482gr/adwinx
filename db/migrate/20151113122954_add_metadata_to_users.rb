class AddMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :metadata, :text, null: false
  end
end
