class ImportItemWorker
  
  include Sidekiq::Worker
  
  # def perform(file_path)
  #   puts "********** Start Importing the items *********"
  #   item_import = ItemImport.new
  #   import_history = ImportHistory.last
  #   #Passe the file path to item_import model
  #   item_import.put_file_path(file_path)
  #   #Passe the import history object to the model
  #   item_import.put_import_hisotry
  #   item_import.save
  #   puts "********** End of Importing the items *********"
  # end
  #
  def perform(file_path)
    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    spreadsheet.map do |row|
      ImportItemRowWorker.perform_async(row.to_hash)
    end
  end
  
  # def perform(import_hisotry_id)
 #    puts "********** Start Importing the items *********"
 #    # item_import = ItemImport.new
 #    # import_hisotry = ImportHistory.find(import_hisotry_id)
 #    #Passe the file path to item_import model
 #    # item_import.put_file_path(file_path)
 #    #Passe the import history object to the model
 #    # item_import.put_import_hisotry(import_hisotry)
 #    # item_import.save
 #
 #    begin
 #      num = rand(0..6)
 #      sleep(num)
 #      Item.where("items.updated_at < ?", 2.days.ago).where(:active => true).first.essendant_xml_import
 #    rescue
 #      puts "No More Items to import"
 #    end while Item.where("items.updated_at < ?", 2.days.ago).where(:active => true).size > 0
 #
 #    puts "********** End of Importing the items *********"
 #
 #    # puts "************** FLUSH FLUSH ~~~~~~~~~~~~~~~~~"
 #  end
  
end