require 'sidekiq-scheduler'

class ProcessOrdersReadyToShipWorker
  include Sidekiq::Worker
  include JobLogger
  
  def perform()
    orders = Order.where(state: "awaiting_shipment").order(:submitted_at)
    puts "------------- #{orders.count}"
    orders.each do |order|
      ScheduledTasks::ProcessOrderByIdWorker.perform_async(order.id)
    end
  end
  
end