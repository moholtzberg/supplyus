class AddEndDateIndexToPrices < ActiveRecord::Migration
  def change
    add_index :prices, :end_date
  end
end
