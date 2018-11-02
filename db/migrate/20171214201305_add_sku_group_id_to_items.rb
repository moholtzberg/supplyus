class AddSkuGroupIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :sku_group_id, :integer
  end
end
