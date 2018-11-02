module DataImports
  
  class ImportItemVendorPricesWorker  
    include Sidekiq::Worker
    include JobLogger

    def perform(file_path, from, to, vendor_id)
      spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
      spreadsheet[from..to].map do |row|
        DataImports::ImportItemVendorPriceRowWorker.perform_async(row.to_hash, vendor_id)
      end
    end
  
  end

end