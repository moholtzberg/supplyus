class ChangeEquipmentTable < ActiveRecord::Migration

  def up
    case connection.adapter_name
      when 'PostgreSQL'
        change_column :equipment, :make, 'integer USING CAST(make AS integer)'
        change_column :equipment, :model, 'integer USING CAST(model AS integer)'
        rename_column :equipment, :make, :make_id
        rename_column :equipment, :model, :model_id
      else
        change_column :equipment, :make, :integer
        change_column :equipment, :model, :integer
        rename_column :equipment, :make, :make_id
        rename_column :equipment, :model, :model_id
    end
  end
  
  def down
    rename_column :equipment, :make_id, :make
    rename_column :equipment, :model_id, :model
    change_column :equipment, :make, :string
    change_column :equipment, :model, :string
  end
  
end
