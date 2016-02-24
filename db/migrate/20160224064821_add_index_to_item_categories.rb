class AddIndexToItemCategories < ActiveRecord::Migration
  def change
    add_index :item_categories, :item_id, :name => 'item_category_item_id_ix'
    add_index :item_categories, :category_id, :name => 'item_category_category_id_ix'
  end
end
