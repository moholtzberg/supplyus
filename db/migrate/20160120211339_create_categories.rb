class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.belongs_to :parent
      t.belongs_to :menu
      t.string :name
      t.string :slug
      t.text :description
      t.boolean :show_in_menu
      t.boolean :active
    end
  end
end
