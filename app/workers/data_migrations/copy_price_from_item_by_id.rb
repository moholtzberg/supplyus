module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPriceFromItemById
    include Sidekiq::Worker
    include JobLogger

    def perform(id, remaining)
      item = Item.find(id)
      Rails.logger.info "Migrating Item with id #{item.id}."
      price = item.prices.create(_type: "Default", price: item.price, combinable: true)
      if price.persisted?
        Rails.logger.info "-------------> #{id} Migrated. #{remaining} remains."
      else
        Rails.logger.error "-------------X #{id} Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
  
  end
  
end