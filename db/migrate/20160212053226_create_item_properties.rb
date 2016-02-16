class CreateItemProperties < ActiveRecord::Migration
  def change
    create_table :item_properties do |t|
      t.belongs_to :item
      t.string :key
      t.string :value
      t.integer :order
      t.boolean :active
    end
  end
end
