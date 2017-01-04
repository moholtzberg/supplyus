class ChangeEquipmentTable < ActiveRecord::Migration
  
  def up
    change_column :equipment, :make, 'integer USING CAST(make AS integer)'
    change_column :equipment, :model, 'integer USING CAST(model AS integer)'
    rename_column :equipment, :make, :make_id
    rename_column :equipment, :model, :model_id
  end
  
  def down
    rename_column :equipment, :make_id, :make
    rename_column :equipment, :model_id, :model
    change_column :equipment, :make, :string
    change_column :equipment, :model, :string
  end
  
end
