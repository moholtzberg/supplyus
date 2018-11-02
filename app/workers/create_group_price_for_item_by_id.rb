require 'sidekiq-scheduler'

class CreateGroupPriceForItemById
  include Sidekiq::Worker
  include JobLogger

  def perform(group_id, item_id, rate)
    item = Item.find(item_id)
    price = (item.cost_price * rate).round(2).to_d.to_s
    unless item.nil?
      price_attributes = {
        item_id: item.id,
        _type: 'Default',
        appliable_type: 'Group',
        appliable_id: group_id,
        price: price,
        start_date: Date.today
      }

      # if prc.size == 0
        # puts Price.where(price_attributes).inspect
        Price.find_or_create_by(price_attributes)
      # end
    end
  end

end