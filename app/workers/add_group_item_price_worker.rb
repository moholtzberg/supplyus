class AddGroupItemPriceWorker
  include Sidekiq::Worker
  include JobLogger

  def perform(item_id, group_id, rate)
    if GroupItemPrice.find_by(item_id: item_id, group_id: group_id)
      add_log "price exists: item_id #{item_id}, group_id #{group_id}"
    else
      price = GroupItemPrice.create(
        item_id: item_id,
        group_id: group_id,
        price: (Item.find(item_id).cost_price * rate).to_d
      )
      add_log "price created: #{price.id}"
    end
  end
end
