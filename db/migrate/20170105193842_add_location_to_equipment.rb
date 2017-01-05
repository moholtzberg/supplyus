class AddLocationToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :location, :string
  end
end
