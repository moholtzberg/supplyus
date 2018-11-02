class AddNumberAndSlugIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :number
    add_index :items, :slug
  end
end
