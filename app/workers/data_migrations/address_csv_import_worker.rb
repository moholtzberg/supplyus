module DataMigrations
  
  class AddressCsvImportWorker
    include Sidekiq::Worker
    include JobLogger

    def perform
      start = Time.now
      add_log 'START'

      begin
        csv = CSV.read('shared/address_export.csv')
      rescue
        add_log 'No such file or wrong format address_export.csv'
        return false
      else
        headers = csv[0].map(&:strip)
        csv[1..-1].each do |row|
          attributes = headers.each_with_index.map { |a, i| [a, row[i].strip] }.to_h
          begin
            Address.create(attributes)
          rescue => error
            add_log error.to_s
          end
        end
        add_log "FINISH TIME ELAPSED -> #{Time.now - start}"
      end
    end
  end
  
end