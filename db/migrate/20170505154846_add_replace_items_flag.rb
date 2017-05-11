class AddReplaceItemsFlag < ActiveRecord::Migration
  def change
    add_column :accounts, :replace_items, :boolean, null: false, default: false
  end
end