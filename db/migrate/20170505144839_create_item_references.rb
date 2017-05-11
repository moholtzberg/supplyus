class CreateItemReferences < ActiveRecord::Migration
  def change
    create_table :item_references do |t|
      t.integer :original_item_id
      t.integer :replacement_item_id
      t.string :original_uom
      t.string :repacement_uom
      t.string :original_uom_qty
      t.string :replacement_uom_qty
      t.string :comments
      t.string :match_type
      t.string :xref_type
      t.timestamps null: false
    end
  end
end
