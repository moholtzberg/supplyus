require 'sidekiq-scheduler'

class RemoveDuplicateItemVendorPriceWorker
  
  include Sidekiq::Worker
  
  def perform(item_id, vendor_id, price)
    puts "Removing Duplicate ItemVendorPrice(item_id: #{item_id}, vendor_id: #{vendor_id}, price: #{price})"
    ItemVendorPrice.where(item_id: item_id, vendor_id: vendor_id, price: price).destroy_all
    ItemVendorPrice.create(item_id: item_id, vendor_id: vendor_id, price: price)
  end
  
end