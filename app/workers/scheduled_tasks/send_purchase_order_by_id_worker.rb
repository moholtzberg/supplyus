module ScheduledTasks
  
  require 'sidekiq-scheduler'

  class SendPurchaseOrderById
    include Sidekiq::Worker
    include JobLogger

    def perform(po_id)
      puts "---------- Sending PO #{po_id}"
      po = PurchaseOrder.find(po_id)
      PurchaseOrderMailer.purchase_order_confirmation(po_id).deliver_later
      po.update_attributes(state: "sent")
    end
  
  end
  
end