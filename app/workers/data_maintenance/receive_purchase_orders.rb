module DataMaintenance
  
  require 'sidekiq-scheduler'

  class ReceivePurchaseOrders
    include Sidekiq::Worker
    include JobLogger
  
    def perform(limit)
      po_ids = PurchaseOrderLineItem.where("quantity_received < quantity").map(&:purchase_order_id)
      po_ids = po_ids.uniq.compact
      PurchaseOrder.where(id: po_ids).order(:id).limit(limit).each do |po|
        DataMaintenance::ReceivePurchaseOrderByIdWorker.perform_async(po.id)
      end
    end
    
  end

end