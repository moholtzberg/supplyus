module DataMaintenance
  
  require 'sidekiq-scheduler'

  class UpdateInventoryIdOnInventoryTransactionById
    include Sidekiq::Worker
    include JobLogger
  
    def perform(it)
      it = InventoryTransaction.find(it)
      itm = it.inv_transaction.order_line_item.item_id
      inv = Inventory.where(item_id: itm, bin_id: 2).first.id; 
      it.update_attributes(inventory_id: inv)
    end
    
  end

end