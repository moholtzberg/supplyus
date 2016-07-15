class CreateOrderTaxRates < ActiveRecord::Migration
  def change
    create_table :order_tax_rates do |t|
      t.belongs_to :order
      t.belongs_to :tax_rate
      t.decimal :amount
      t.timestamps
    end
  end
end
