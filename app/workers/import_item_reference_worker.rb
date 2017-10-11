class ImportItemReferenceWorker
  include Sidekiq::Worker
  include JobLogger

  def perform(file_path)
    add_log "********** Start Importing Item References *********"
    item_import = ItemReferenceImport.new
    import_history = ImportHistory.last
    item_import.put_file_path(file_path)
    item_import.put_import_history(import_history)
    item_import.save
    add_log "********** End of Importing the items *********"
  end
end
