module DataMigrations
  
  class AssetUpdateAttachableCsvWorker
    include Sidekiq::Worker
    include JobLogger

    def perform
      start = Time.now
      add_log 'START'

      begin
        csv = CSV.read('shared/asset_export.csv')
      rescue
        add_log 'No such file or wrong format address_export.csv'
        return false
      else
        headers = csv[0].map(&:strip)
        csv[1..-1].each do |row|
          id = row[headers.index('id')].strip
          item_id = row[headers.index('item_id')].strip
          asset = Asset.find(id)
          next unless asset && item_id.present?
          asset.update_attributes(
            attachable_type: 'Item',
            attachable_id: item_id
          )
        end
        add_log "FINISH TIME ELAPSED -> #{Time.now - start}"
      end
    end
  end

end