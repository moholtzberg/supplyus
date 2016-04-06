class CreateGroupItemPrices < ActiveRecord::Migration
  def change
    create_table :group_item_prices do |t|
      t.belongs_to :group, :index => true
      t.belongs_to :item, :index => true
      t.float :price
      t.boolean :active
      t.timestamps
    end
  end
end