class AddIndexToCategories < ActiveRecord::Migration
  def change
    add_index :categories, :id, :name => 'category_id_ix'
    add_index :categories, :parent_id, :name => 'category_parent_id_ix'
  end
end
