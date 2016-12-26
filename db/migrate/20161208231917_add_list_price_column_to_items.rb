class AddListPriceColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :list_price, :decimal, :precision => 10, :scale => 2
  end
end
