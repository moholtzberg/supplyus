class AddBinIdToInventories < ActiveRecord::Migration
  def change
    add_column :inventories, :bin_id, :integer
  end
end
