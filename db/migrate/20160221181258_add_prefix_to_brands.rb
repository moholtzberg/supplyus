class AddPrefixToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :prefix, :string
  end
end
