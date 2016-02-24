class AddIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :id, :name => 'item_id_ix'
  end
end
