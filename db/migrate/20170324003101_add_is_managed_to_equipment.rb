class AddIsManagedToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :is_managed, :boolean, :default => false
  end
end