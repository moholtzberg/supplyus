class AddMigratedToAccountItemPriceGroupItemPrice < ActiveRecord::Migration
  def change
    add_column :account_item_prices, :migrated, :boolean, default: false
    add_column :group_item_prices, :migrated, :boolean, default: false
  end
end
