require 'sidekiq-scheduler'

class ImportItemReferenceWorker
  
  include Sidekiq::Worker
  
  def perform(file_path, records)
    puts "********** Start Importing the items and building references *********"
    
    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    puts "---->>>>>>> #{spreadsheet}"
    # history = ImportHistory.last
    # history.update(nb_in_queue: spreadsheet.size)
    
    spreadsheet.first(records).map do |row|
      puts "---->>> #{row}" 
      original_item = Item.find_by(number: row["reseller_item_number"])
      puts "----> #{original_item}"
      replacement_item = Item.find_by(number: row["essendant_item_number"])
      puts "----> #{replacement_item}"
      if original_item and replacement_item
        puts "----> #{original_item} + #{replacement_item.id}"
        unless ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
          ref = ItemReference.create(original_item_id: original_item.id, replacement_item_id: replacement_item.id, original_uom: row["essendant_uom"], repacement_uom: row["reseller_uom"], original_uom_qty: row["essendant_uom_qty"], replacement_uom_qty: row["reseller_uom_qty"], comments: row["comments"], match_type: row["match_type"], xref_type: row["xref_type"])
          puts "----> #{ref}"
        else
          i =  ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
          i.update_attributes(original_item_id: original_item.id, replacement_item_id: replacement_item.id, original_uom: row["essendant_uom"], repacement_uom: row["reseller_uom"], original_uom_qty: row["essendant_uom_qty"], replacement_uom_qty: row["reseller_uom_qty"], comments: row["comments"], match_type: row["match_type"], xref_type: row["xref_type"])
        end
      end
    end
    
    puts "********** End of Importing the items *********"
  end
  
end