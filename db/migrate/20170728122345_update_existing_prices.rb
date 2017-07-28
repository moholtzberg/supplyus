class UpdateExistingPrices < ActiveRecord::Migration
  def change
    Price.all.each do |price|
      price.set_blank_to_nil
      price.save
    end
  end
end
