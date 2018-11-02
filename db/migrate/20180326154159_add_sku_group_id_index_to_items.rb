class AddSkuGroupIdIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :sku_group_id
  end
end
