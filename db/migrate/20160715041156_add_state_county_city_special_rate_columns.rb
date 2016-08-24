class AddStateCountyCitySpecialRateColumns < ActiveRecord::Migration
  def change
    add_column :tax_rates, :state_rate, :float
    add_column :tax_rates, :county_rate, :float
    add_column :tax_rates, :city_rate, :float
    add_column :tax_rates, :special_rate, :float
    add_column :tax_rates, :region_code, :string
    change_column :tax_rates, :state_id, :string
    rename_column :tax_rates, :state_id, :state_code
    rename_column :tax_rates, :authority, :region_name
  end
end
