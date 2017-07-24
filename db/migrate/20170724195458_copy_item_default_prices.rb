class CopyItemDefaultPrices < ActiveRecord::Migration
  def change
    Item.all.each do |item|
      item.prices.create(_type: "Default", price: item.price, combinable: true)
    end
  end
end
