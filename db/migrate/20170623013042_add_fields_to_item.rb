class AddFieldsToItem < ActiveRecord::Migration
  def change
    add_column :items, :green_indicator, :boolean
    add_column :items, :recycle_indicator, :boolean
    add_column :items, :small_package_indicator, :boolean
    add_column :items, :assembly_code, :string
    add_column :items, :non_returnable_code, :string
  end
end
