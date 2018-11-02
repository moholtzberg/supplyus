class CreateSkuGroup < ActiveRecord::Migration
  def change
    create_table :sku_groups do |t|
      t.string :name
    end
  end
end
