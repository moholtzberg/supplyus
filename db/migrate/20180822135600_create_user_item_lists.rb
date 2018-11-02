class CreateUserItemLists < ActiveRecord::Migration
  def change
    create_table :user_item_lists do |t|
      t.belongs_to :user
      t.belongs_to :item_list
    end
  end
end
