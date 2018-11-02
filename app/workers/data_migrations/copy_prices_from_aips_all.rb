module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPricesFromAipsAll
    include Sidekiq::Worker
    include JobLogger

    def perform(limit)
      aips = AccountItemPrice.where(migrated: false).limit(limit)
      aips.order(:id).each_with_index do |item, index|
        remaining = aips.size - (index + 1)
        CopyPriceFromAipById::perform_async(item.id, remaining)
      end
    end
  
  end
  
end