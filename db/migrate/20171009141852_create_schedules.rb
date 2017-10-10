class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.text :cron
      t.text :worker
      t.text :name
      t.text :arguments, array: true, default: []
      t.text :description
      t.boolean :enabled, default: true
      t.timestamps
    end
  end
end
