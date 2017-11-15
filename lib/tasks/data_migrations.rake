namespace :data_migrations do
  desc 'creates addresses from account data'
  task addresses_from_accounts: :environment do
    Account.includes(:addresses).where(addresses: {account_id: nil}).each do |account|
      Rails.logger.info "Migrating account #{account.id} addresses."
      ship_address = Address.create({
        account_id: account.id,
        address_1: account.ship_to_address_1,
        address_2: account.ship_to_address_2,
        city: account.ship_to_city,
        state: account.ship_to_state,
        zip: account.ship_to_zip,
        phone: account.ship_to_phone,
        fax: account.ship_to_fax,
        name: 'shipping',
        main: true
      })
      bill_address = Address.create({
        account_id: account.id,
        address_1: account.bill_to_address_1,
        address_2: account.bill_to_address_2,
        city: account.bill_to_city,
        state: account.bill_to_state,
        zip: account.bill_to_zip,
        phone: account.bill_to_phone,
        fax: account.bill_to_fax,
        name: 'billing',
        main: false
      })
      if ship_address.persisted? and bill_address.persisted?
        Rails.logger.info "Migrated. #{pluralize(Account.includes(:addresses).where(addresses: {account_id: nil}), 'account')} remain."
      else
        [ship_address, bill_address].each do |address|
          Rails.logger.error "Not migrated: #{address.errors.full_messages.join(', ')}"
          address.destroy
        end
      end
    end
  end

  desc 'migrates Price from AccountItemPrice & GroupItemPrice items'
  task prices_from_aip_gip: :environment do
    AccountItemPrice.where(migrated: false).each do |aip|
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
        Rails.logger.info "Migrated. #{AccountItemPrice.where(migrated: false).count} remains."
      else
        Rails.logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
    GroupItemPrice.where(migrated: false).each do |gip|
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
        Rails.logger.info "Migrated. #{GroupItemPrice.where(active: true, migrated: false).count} remains."
      else
        Rails.logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
  end

  desc 'migrates Price from default Item prices'
  task prices_from_items: :environment do
    items_ok = Item.joins('LEFT JOIN prices ON items.id = prices.item_id')
                   .where('prices._type = \'Default\' AND prices.price = items.price')
    Item.where.not(id: items_ok.ids.uniq, price: nil).each do |item|
      Rails.logger.info "Migrating Item with id #{item.id}."
      price = item.prices.create(_type: "Default", price: item.price, combinable: true)
      if price.persisted?
        Rails.logger.info "Migrated. #{Item.where.not(id: items_ok.ids.uniq, price: nil).count} remains."
      else
        Rails.logger.error "Not migrated: #{price.errors.full_messages.join(', ')}"
      end
    end
  end

  desc 'changes Price appliable_type to blank if nil'
  task prices_blank_to_nil: :environment do
    Price.where(appliable_type: '').update_all(appliable_type: nil)
  end

  desc 'creates main payment service for each account'
  task main_payment_service_for_accounts: :environment do
    Account.where.not(id: Account.joins(:account_payment_services).pluck(:id)).each do |account|
      account.set_payment_services
      if account.save
        Rails.logger.info "Successfully created payment service for account #{account.id}"
      else
        Rails.logger.error "Not migrated: #{account.errors.full_messages.join(', ')}"
      end
    end
  end

  desc 'adds customer role for users without roles'
  task customer_role_for_users: :environment do
    User.where.not(id: User.joins(:users_roles)).each { |user| user.add_role :customer }
  end

  desc 'changes Order state to incomplete if new'
  task orders_new_to_incomplete: :environment do
    Order.where(state: :new).update_all(state: :incomplete)
  end

  desc 'resets positions for assets'
  task reset_asset_position: :environment do
    Item.all.each do |item|
      item.assets.each_with_index do |asset, index|
        asset.update_column(:position, index + 1)
      end
    end
  end

  desc 'ensure category slug uniqueness'
  task ensure_category_slug_uniqueness: :environment do
    Category.select(:slug).group(:slug).having("count(*) > 1").each do |slug|
      i = 1
      Category.where(slug: slug.slug).each_with_index do |cat, idx|
        cat.update_column(:slug, "#{slug.slug}_#{i}") if idx > 0
      end
    end
  end

  desc 'ensure item slug uniqueness'
  task ensure_item_slug_uniqueness: :environment do
    Item.select(:slug).group(:slug).having("count(*) > 1").each do |slug|
      i = 1
      Item.where(slug: slug.slug).each_with_index do |item, idx|
        item.update_column(:slug, "#{slug.slug}_#{i}") if idx > 0
      end
    end
  end

  desc 'create schedule items'
  task create_schedule_items: :environment do
    schedules = YAML::load_file(File.join(__dir__, '../../config/schedules.yml'))
    schedules.each do |k, v|
      Schedule.create(
        name: k,
        worker: v['class'] || k,
        enabled: v['enabled'] || true,
        cron: v['cron'],
        arguments: v['args'],
        description: v['description']
      )
    end
  end

  desc 'set Order state for existing orders'
  task order_set_state: :environment do
    Order.where(state: nil).each do |order|
      state = if order.paid && order.shipped && order.fulfilled
                'completed'
              elsif order.paid && order.shipped
                'awaiting_fulfillment'
              elsif order.paid && order.fulfilled
                'awaiting_shipment'
              elsif order.shipped && order.fulfilled
                'fulfilled'
              elsif order.paid
                'awaiting_shipment'
              elsif order.shipped
                'awaiting_fulfillment'
              elsif order.fulfilled
                'fulfilled'
              elsif order.quantity == 0
                'canceled'
              elsif order.submitted_at.present?
                'pending'
              else
                'incomplete'
              end
      if order.update_column(:state, state)
        Rails.logger.info "Migrated. #{Order.where(state: nil).count} remains."
      else
        Rails.logger.error "Not migrated: #{order.errors.full_messages.join(', ')}"
      end
    end
  end
end
