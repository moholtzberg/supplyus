class AddGroupItemPriceWorker
  
  include Sidekiq::Worker
  
  def perform(item_id, group_id, rate)
    unless GroupItemPrice.find_by(item_id: item_id, group_id: group_id)
      GroupItemPrice.create(item_id: item_id, group_id: group_id, price: (Item.find(item_id).cost_price * rate).to_d)
    end
  end
  
end