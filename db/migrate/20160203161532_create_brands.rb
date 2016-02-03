class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.boolean :active
      t.boolean :preferred
      t.timestamps
    end
  end
end
