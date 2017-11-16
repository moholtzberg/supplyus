class AddAttachableToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :attachable_id, :integer
    add_column :assets, :attachable_type, :string
    remove_column :assets, :item_id, :integer
  end
end
