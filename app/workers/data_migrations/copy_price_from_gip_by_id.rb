module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPriceFromGipById
    include Sidekiq::Worker
    include JobLogger

    def perform(id, remaining)
      gip = GroupItemPrice.find(id)
      Rails.logger.info "Migrating GroupItemPrice with id #{gip.id}."
      price_attributes = {
        item_id: gip.item_id,
        _type: 'Default',
        appliable_type: 'Group',
        appliable_id: gip.group_id,
        price: gip.price
      }
      price = Price.find_or_create_by(price_attributes)
    
      if price.persisted?
        gip.update_column(:migrated, true)
        Rails.logger.info "Migrated. #{remaining} remains."
      else
        Rails.logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    
    end
  
  end
  
end