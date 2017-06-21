require 'sidekiq-scheduler'

class RemoveDuplicateGroupItemPrice
  
  include Sidekiq::Worker
  
  def perform(item_id, group_id, price)
    puts "Removing Duplicate GroupItemPrice(item_id: #{item_id}, vendor_id: #{group_id}, price: #{price})"
    GroupItemPrice.where(item_id: item_id, group_id: group_id, price: price).destroy_all
    GroupItemPrice.create(item_id: item_id, group_id: group_id, price: price)
  end
  
end