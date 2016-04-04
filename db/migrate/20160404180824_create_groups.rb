class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :group_type
      t.string :name
      t.string :slug
      t.string :description
      t.timestamps
    end
  end
end
