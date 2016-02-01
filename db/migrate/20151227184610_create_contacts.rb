class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.belongs_to :account
      t.belongs_to :user
      t.string :number
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
    end
  end
end
