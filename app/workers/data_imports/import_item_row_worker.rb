module DataImports
  
  class ImportItemRowWorker  
    include Sidekiq::Worker
    include JobLogger

    def perform(row)
      puts "------------n--> #{row['number']}"
      puts "------------f--> #{Item.find_by(number: row['number']).inspect}"
      if Item.find_by(number: row["number"]).nil?
        item = Item.new
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        item.number = row["number"]
      else
        item = Item.find_by(number: row["number"])
        id = item.id
        name = item.name
        item.attributes = row.to_hash.slice(*Item.attribute_names())
        
        item.name = name
        item.number = row["number"]
        item.id = id
      end
      puts "-------------> #{item.inspect}"
      if item.default_price.price != row["default_price"]
        puts item.default_price.price
        puts row["default_price"]
        
        case row["cost_price"].to_d 
        when 500..Float::INFINITY
          dflt_prc = (row["cost_price"].to_d * 1.19)
        when 250..500
          dflt_prc = (row["cost_price"].to_d * 1.20)
        when 100..250
          dflt_prc = (row["cost_price"].to_d * 1.21)
        when 90..100
          dflt_prc = (row["cost_price"].to_d * 1.22)
        when 80..90
          dflt_prc = (row["cost_price"].to_d * 1.23)
        when 70..80
          dflt_prc = (row["cost_price"].to_d * 1.24)
        when 60..70
          dflt_prc = (row["cost_price"].to_d * 1.25)
        when 50..60
          dflt_prc = (row["cost_price"].to_d * 1.26)
        when 45..50
          dflt_prc = (row["cost_price"].to_d * 1.27)
        when 40..45
          dflt_prc = (row["cost_price"].to_d * 1.28)
        when 35..40
          dflt_prc = (row["cost_price"].to_d * 1.29)
        when 30..35
          dflt_prc = (row["cost_price"].to_d * 1.30)
        when 25..30
          dflt_prc = (row["cost_price"].to_d * 1.31)
        when 20..25
          dflt_prc = (row["cost_price"].to_d * 1.32)
        when 15..20
          dflt_prc = (row["cost_price"].to_d * 1.33)
        when 10..15
          dflt_prc = (row["cost_price"].to_d * 1.34)
        when 9..10
          dflt_prc = (row["cost_price"].to_d * 1.35)
        when 7..8
          dflt_prc = (row["cost_price"].to_d * 1.36)
        when 6..7
          dflt_prc = (row["cost_price"].to_d * 1.37)
        when 5..6
          dflt_prc = (row["cost_price"].to_d * 1.38)
        when 4..5
          dflt_prc = (row["cost_price"].to_d * 1.39)
        when 3..4
          dflt_prc = (row["cost_price"].to_d * 1.40)
        when 2..3
          dflt_prc = (row["cost_price"].to_d * 1.41)
        when 1..2
          dflt_prc = (row["cost_price"].to_d * 1.42)
        else
          dflt_prc = (row["cost_price"].to_d * 1.75)
        end
        puts "--> #{row["number"]} - COST: #{row["cost_price"]}, LIST: #{row["default_price"]}, DFLT: #{dflt_prc.to_d.to_s}"
        dflt_prc = [dflt_prc.to_d, row["default_price"].to_d].min
        puts "--X #{row["number"]}, PRICE: #{dflt_prc}"
        puts "--Y #{item.default_price.inspect} #{item.default_price&.price&.to_s}"
        puts "--Z #{item.default_price.nil?}"
        item.prices.new(_type: "Default", start_date: Date.today, price: dflt_prc.to_d)
        item.default_price&.update_attributes(end_date: Date.today) unless item.default_price.nil?
      end
      
      if item.item_vendor_prices.where(:vendor_id => 106).nil? or item.item_vendor_prices.where(:vendor_id => 106).order(:created_at).last&.price != row["cost_price"]
        item.item_vendor_prices.new(vendor_id: 106, price: row["cost_price"])
      end
      
      item.save!
      add_log "-----> #{item.inspect}"
    end
  
  end
  
end