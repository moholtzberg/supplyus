class NewMigratePricesToNewModel < ActiveRecord::Migration
  def self.up
    AccountItemPrice.where(migrated: false).each do |aip|
      logger.info "Migrating AccountItemPrice with id #{aip.id}."
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
        logger.info "Migrated. #{AccountItemPrice.where(migrated: false).count} remains."
      else
        logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
    GroupItemPrice.where(active: true, migrated: false).each do |gip|
      logger.info "Migrating GroupItemPrice with id #{gip.id}."
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
        logger.info "Migrated. #{GroupItemPrice.where(active: true, migrated: false).count} remains."
      else
        logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
  end

  def self.down

  end
end
