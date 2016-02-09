class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.belongs_to :make
      t.string :number
      t.string :name
      t.timestamps null: false
    end
  end
end
