class DropAccountItemPricesTable < ActiveRecord::Migration
  def change
    drop_table :account_item_prices
  end
end
