module DataImports
  
  class ImportItemVendorPriceRowWorker  
    include Sidekiq::Worker
    include JobLogger

    def perform(row, vendor_id)
      puts "------------n--> #{row['number']}"
      puts "------------f--> #{Item.find_by(number: row['number']).inspect}"
      if Item.find_by(number: row["number"])
        item = Item.find_by(number: row["number"])
        item_id = item.id
        puts row["cost_price"] 
        
        if item.item_vendor_prices.where(vendor_id: vendor_id).nil? or item.item_vendor_prices.where(vendor_id: vendor_id).order(:created_at).last&.price != row["cost_price"]
          item.item_vendor_prices.create(item_id: item_id, vendor_id: vendor_id, price: row["cost_price"].to_d)
        end
        
      end
    end
  
  end
  
end