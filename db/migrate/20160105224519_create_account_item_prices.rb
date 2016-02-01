class CreateAccountItemPrices < ActiveRecord::Migration
  def change
    create_table :account_item_prices do |t|
      t.integer :account_id
      t.integer :item_id
      t.float :price
      t.timestamps null: false
    end
  end
end
