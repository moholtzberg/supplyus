class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :item_id
      t.string :type
      t.integer :attachment_width
      t.integer :attachment_height
      t.integer :attachment_file_size
      t.integer :position
      t.string :attachment_content_type
      t.string :attachment_file_name
      t.datetime :attachment_updated_at
      t.text :alt
      t.timestamps
    end
  end
end
