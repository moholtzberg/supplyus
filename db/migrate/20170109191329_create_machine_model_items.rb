class CreateMachineModelItems < ActiveRecord::Migration
  def change
    create_table :machine_model_items do |t|
      t.belongs_to :machine_model
      t.belongs_to :item
      t.string :supply_type
      t.string :supply_color
      t.integer :priority
      t.timestamps
    end
  end
end
