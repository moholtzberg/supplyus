class CreateItemItemLists < ActiveRecord::Migration
  def change
    create_table :item_item_lists do |t|
      t.belongs_to :item, index: true
      t.belongs_to :item_list, index: true
    end
  end
end
