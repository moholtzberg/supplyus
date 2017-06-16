class CreateItemLists < ActiveRecord::Migration
  def change
    create_table :item_lists do |t|
      t.string :name
      t.integer :user_id
    end
  end
end
