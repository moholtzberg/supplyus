class CreateMeterReadings < ActiveRecord::Migration
  def change
    create_table :meter_readings do |t|
      t.belongs_to :meter
      t.float :display
      t.string :source
      t.boolean :is_valid
      t.boolean :is_estimate
    end
  end
end
