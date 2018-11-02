class AddIndexToPrices < ActiveRecord::Migration
  def change
    add_index :prices, :id, :name => 'prices_id_ix'
    add_index :prices, :item_id
    add_index :prices, :appliable_type
    add_index :prices, :appliable_id
    add_index :prices, :_type
    add_index :prices, :start_date
  end
end
