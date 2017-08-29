class AddSlugIndexToCategories < ActiveRecord::Migration
  def change
    add_index :categories, :slug, :unique => true
    Category.find_each(&:save)
  end
end
