class CreateImportHistories < ActiveRecord::Migration
  def change
    create_table :import_histories do |t|
      t.integer :nb_imported
      t.integer :nb_failed
      t.integer :nb_in_queue

      t.timestamps null: false
    end
  end
end
