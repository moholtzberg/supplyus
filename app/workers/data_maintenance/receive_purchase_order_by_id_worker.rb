module DataMaintenance
  
  require 'sidekiq-scheduler'

  class ReceivePurchaseOrderByIdWorker
    include Sidekiq::Worker
    include JobLogger
  
    def perform(po_id)
      po = PurchaseOrder.find(po_id)
      receipt = PurchaseOrderReceipt.new
      receipt.date = po.completed_at
      po.purchase_order_line_items.each do |poli|
        receipt.purchase_order_line_item_receipts.build(purchase_order_line_item_id: poli.id, date: po.completed_at, bin: Bin.find(2), quantity_received: poli.quantity)
      end
      receipt.save
    end
    
  end
  
end