class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.text :cron
      t.text :worker
      t.text :name
      t.text :arguments
      t.text :description
      t.boolean :enabled, default: true
    end
  end
end
