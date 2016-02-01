class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.belongs_to :equipment
      t.string :meter_type
    end
  end
end
