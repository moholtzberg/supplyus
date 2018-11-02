module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPriceFromAipById
    include Sidekiq::Worker
    include JobLogger

    def perform(id, remaining)
      aip = AccountItemPrice.find(id)
      Rails.logger.info "Migrating AccountItemPrice with id #{aip.id}."
      price_attributes = {
        item_id: aip.item_id,
        _type: 'Default',
        appliable_type: 'Account',
        appliable_id: aip.account_id,
        price: aip.price
      }
      price = Price.find_or_create_by(price_attributes)
    
      if price.persisted?
        aip.update_column(:migrated, true)
        Rails.logger.info "Migrated. #{remaining} remains."
      else
        Rails.logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    
    end
  
  end
  
end