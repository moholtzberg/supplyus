class DropGroupItemPricesTable < ActiveRecord::Migration
  def change
    drop_table :group_item_prices
  end
end
