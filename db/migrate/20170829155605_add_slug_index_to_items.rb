class AddSlugIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :slug, :unique => true
    Item.find_each(&:save)
  end
end
