module DataMigrations
  
  class AssetUpdateRowWorker
    include Sidekiq::Worker
    include JobLogger
  
    def perform(headers, row)
      id = row[headers.index('id')].strip
      item_id = row[headers.index('item_id')].strip
      asset = Asset.find(id)
      if asset && item_id.present?
        asset.update_attributes(
          attachable_type: 'Item',
          attachable_id: item_id
        )
      end
    end
  
  end
  
end