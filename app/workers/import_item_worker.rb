class ImportItemWorker
  include Sidekiq::Worker

  def perform(file_path, import_hisotry_id)
  	puts "**********Start Importing the items*********"
  	item_import = ItemImport.new
    import_hisotry = ImportHistory.find(import_hisotry_id)
    #Passe the file path to item_import model
  	item_import.put_file_path(file_path)
    #Passe the import history object to the model
  	item_import.put_import_hisotry(import_hisotry)
  	item_import.save	
  	puts "**********End of Importing the items*********"
  end
end