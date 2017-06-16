class ImportItemRowWorker
  
  include Sidekiq::Worker
  
  def perform(row)
    puts "-----> #{row.inspect}"
    if row["price"].to_f > 0 and row["cost_price"].to_f > 0
      unless Item.find_by(number: row["number"])
        puts "#{row["number"]} line 8"
        item = Item.new
        # item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.name = row["name"]
      else
        puts "#{row["number"]} line 13"
        item = Item.find_by(number: row["number"])
        id = item.id
        # item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.number = row["number"]
        item.id = id
      end
      item.price = row["price"]
      item.cost_price = row["cost_price"]
      item.brand_name = row["brand_name"]
      item.list_price = row["list_price"]
      item.item_vendor_prices.new(vendor_id: 106, price: row["cost_price"])
      item.save
    end
  end
  
end