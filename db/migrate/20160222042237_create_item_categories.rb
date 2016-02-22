class CreateItemCategories < ActiveRecord::Migration
  def change
    create_table :item_categories do |t|
      t.belongs_to :category
      t.belongs_to :item
    end
  end
end
