class RemoveSlugIndexFromItemsCategories < ActiveRecord::Migration
  def change
    remove_index :categories, :slug
    remove_index :items, :slug
  end
end
