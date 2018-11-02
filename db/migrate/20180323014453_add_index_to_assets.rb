class AddIndexToAssets < ActiveRecord::Migration
  def change
    add_index :assets, :id
    add_index :assets, :type
    add_index :assets, :attachable_type
    add_index :assets, :attachable_id
  end
end
