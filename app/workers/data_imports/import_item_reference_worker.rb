module DataImports
  
  class ImportItemReferenceWorker
    include Sidekiq::Worker
    include JobLogger

    def perform(file_path, from, to)
      puts "********** Start Importing Item References *********"
      # item_import = ItemReferenceImport.new
      # import_history = ImportHistory.last
      # item_import.put_file_path(file_path)
      # item_import.put_import_history(import_history)
      # item_import.save
      spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
      spreadsheet[from..to].each_with_index do |row, index|
        DataImports::ImportItemReferenceRowWorker.perform_async(row.to_hash, index)
      end
      puts "********** End of Importing the items *********"
    end
  end
  
end