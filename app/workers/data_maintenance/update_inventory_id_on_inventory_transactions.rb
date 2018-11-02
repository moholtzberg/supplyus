module DataMaintenance
  
  require 'sidekiq-scheduler'

  class UpdateInventoryIdOnInventoryTransactions
    include Sidekiq::Worker
    include JobLogger
  
    def perform(limit)
      InventoryTransaction.where(inv_transaction_type: "LineItemShipment", inventory_id: nil).order(:id).limit(limit).each do |it|
        DataMaintenance::UpdateInventoryIdOnInventoryTransactionById.perform_async(it.id)
      end
    end
    
  end

end