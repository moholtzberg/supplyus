module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPricesFromGipsAll
    include Sidekiq::Worker
    include JobLogger

    def perform(limit)
      gips = GroupItemPrice.where(migrated: false).limit(limit)
      gips.order(:id).each_with_index do |item, index|
        remaining = gips.size - (index + 1)
        CopyPriceFromGipById::perform_async(item.id, remaining)
      end
    end
  
  end

end