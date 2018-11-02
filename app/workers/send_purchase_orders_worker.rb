require 'sidekiq-scheduler'

class SendPurchaseOrdersWorker  
  include Sidekiq::Worker
  include JobLogger

  def perform
    puts "sending PO's"
    PurchaseOrder.where(locked: true, state: "not_sent", canceled: nil).each do |po|
      ScheduledTasks::SendPurchaseOrderById.perform_async(po.id)
    end
  end
  
end
