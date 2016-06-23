class CreatePermissions < ActiveRecord::Migration
  def up
    create_table :permissions do |t|
      t.string :mdl_name, null: false

      t.boolean :can_create, null: false, default: false
      t.boolean :can_read, null: false, default: false
      t.boolean :can_update, null: false, default: false
      t.boolean :can_destroy, null: false, default: false

      t.references :role, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :permissions
  end
end
