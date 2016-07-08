class AddDatesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :created_at, :datetime
    add_column :payments, :updated_at, :datetime
    add_column :payments, :date, :datetime
  end
end