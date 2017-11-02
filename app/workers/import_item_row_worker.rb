class ImportItemRowWorker  
  include Sidekiq::Worker
  include JobLogger

  def perform(row)
    add_log "#{Item.find_by(number: row["number"]).inspect}"
    if Item.find_by(number: row["number"]).nil?
      item = Item.new
      item.attributes = row.to_hash.slice(*Item.attribute_names())
      item.number = row["number"]
    else
      item = Item.find_by(number: row["number"])
      id = item.id
      item.attributes = row.to_hash.slice(*Item.attribute_names())
      item.number = row["number"]
      item.id = id
    end
    item.price = row["price"]
    item.cost_price = row["cost_price"]
    item.brand_name = row["brand_name"]
    item.list_price = row["list_price"]
    item.item_vendor_prices.new(vendor_id: 106, price: row["cost_price"])
    item.save
    add_log "-----> #{item.inspect}"
  end
  
end