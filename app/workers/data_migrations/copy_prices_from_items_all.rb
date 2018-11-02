module DataMigrations
  
  require 'sidekiq-scheduler'

  class CopyPricesFromItemsAll
    include Sidekiq::Worker
    include JobLogger

    def perform(limit)
      items_ok = Item.joins('LEFT JOIN prices ON items.id = prices.item_id').where('prices._type = \'Default\' AND prices.price = items.price')
      items_not_ok = Item.where.not(id: items_ok.ids.uniq, price: nil).limit(limit)
      items_not_ok_size = items_not_ok.size
      items_not_ok.order(:id).each_with_index do |item, index|
        remaining = items_not_ok_size - (index + 1)
        CopyPriceFromItemById::perform_async(item.id, remaining)
      end
    end
  
  end

end