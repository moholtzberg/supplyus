class CreateInventoryTransactions < ActiveRecord::Migration
  def change
    create_table :inventory_transactions do |t|
      t.belongs_to :item, :null => false
      t.integer :inv_transaction_id, :null => false
      t.string :inv_transaction_type, :null => false
      t.integer :quantity, :null => false, :default => 0
      t.string :notes
      t.timestamps
    end
  end
end