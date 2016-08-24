class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.belongs_to :state
      t.string :authority
      t.string :zip_code
      t.float :rate
      t.timestamps
    end
  end
end
