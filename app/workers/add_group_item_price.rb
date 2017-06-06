require 'sidekiq-scheduler'

class AddGroupItemPrice
  
  include Sidekiq::Worker
  
  def perform(item_id, group_id)
    GroupItemPrice.create(item_id: item_id, group_id: group_id, price: (Item.find(item_id).cost_price * 1.21).to_d)
  end
  
end