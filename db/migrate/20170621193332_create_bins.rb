class CreateBins < ActiveRecord::Migration
  def change
    create_table :bins do |t|
      t.string :name
      t.string :_type
      t.integer :warehouse_id
    end
  end
end
