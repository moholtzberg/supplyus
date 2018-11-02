require 'sidekiq-scheduler'

class CreateGroupItemPrices
  include Sidekiq::Worker
  include JobLogger

  def perform(group_id, start_id, end_id, rate)
    group = Group.find(group_id)
    
    unless group.nil?
      item_ids = Item.where(id: start_id..end_id).order(:id).ids
      item_ids.each do |item_id|
        CreateGroupPriceForItemById.perform_async(group.id, item_id, rate)
      end
    end
    
  end
end