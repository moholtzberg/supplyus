class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :item_id
      t.integer :min_qty
      t.integer :max_qty
      t.string :_type, default: 'Default'
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :combinable, default: false
      t.integer :appliable_id
      t.string :appliable_type
      t.decimal :price, :precision => 10, :scale => 2
    end
  end
end
