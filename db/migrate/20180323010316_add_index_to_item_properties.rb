class AddIndexToItemProperties < ActiveRecord::Migration
  def change
    add_index :item_properties, :id, :name => 'item_properties_id_ix'
    add_index :item_properties, :item_id, :name => 'item_properties_item_id_ix'
    add_index :item_properties, :key
    add_index :item_properties, :value
    add_index :item_properties, :type
  end
end
