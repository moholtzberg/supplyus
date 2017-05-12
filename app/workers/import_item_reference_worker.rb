require 'sidekiq-scheduler'

class ImportItemReferenceWorker
  
  include Sidekiq::Worker
  
  def perform(file_path)
    puts "********** Start Importing Item References *********"
    item_import = ItemReferenceImport.new
    import_history = ImportHistory.last
    item_import.put_file_path(file_path)
    item_import.put_import_history(import_history)
    item_import.save
    puts "********** End of Importing the items *********"
  end
  
end