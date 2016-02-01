class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :account
      t.text :number
      t.date :date
      t.float :total
    end
  end
end
