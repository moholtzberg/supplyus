class AddTypeToItemProperties < ActiveRecord::Migration
  def change
    add_column :item_properties, :type, :string, :default => "Specification"
  end
end