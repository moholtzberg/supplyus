class CreateTrackingNumbers < ActiveRecord::Migration
  def change
    create_table :tracking_numbers do |t|
      t.belongs_to :shipment
      t.belongs_to :carrier
      t.string :number
      t.boolean :delivered
      t.string :signed_by
    end
  end
end
