module DataMaintenance
  
  require 'sidekiq-scheduler'

  class RemoveDuplicateItemVendorPriceWorker  
    include Sidekiq::Worker
    include JobLogger
  
    def perform(item_id, vendor_id, price)
      add_log "Removing Duplicate ItemVendorPrice(item_id: #{item_id}, vendor_id: #{vendor_id}, price: #{price})"
      ItemVendorPrice.where(item_id: item_id, vendor_id: vendor_id, price: price).destroy_all
      ItemVendorPrice.create(item_id: item_id, vendor_id: vendor_id, price: price)
    end
  end

end