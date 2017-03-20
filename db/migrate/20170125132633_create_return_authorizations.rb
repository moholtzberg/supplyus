class CreateReturnAuthorizations < ActiveRecord::Migration
  def change
    create_table :return_authorizations do |t|
      t.string :number
      t.belongs_to :order
      t.belongs_to :customer
      t.integer :reviewer_id
      t.string :reason
      t.string :status
      t.datetime :date
      t.datetime :expiration_date
      t.text :notes
      t.timestamps null: false
    end
  end
end