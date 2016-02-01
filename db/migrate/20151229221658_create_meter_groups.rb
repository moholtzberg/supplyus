class CreateMeterGroups < ActiveRecord::Migration
  def change
    create_table :meter_groups do |t|

      t.timestamps null: false
    end
  end
end
