class ChangeInventoryTransactionsAssociation < ActiveRecord::Migration
  def change
    remove_column :inventory_transactions, :item_id, :integer
    add_column :inventory_transactions, :inventory_id, :integer
  end
end
