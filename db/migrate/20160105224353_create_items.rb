class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :item_type_id
      t.integer :category_id
      t.integer :model_id
      t.boolean :is_serialized
      t.string :number, :null => false
      t.string :name
      t.string :slug
      t.text :description
      t.float :price
      t.float :sale_price
      t.float :cost_price
      t.float :weight
      t.float :height
      t.float :width
      t.float :length
      t.timestamps null: false
    end
  end
end