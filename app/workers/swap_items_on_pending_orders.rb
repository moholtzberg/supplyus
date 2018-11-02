require 'sidekiq-scheduler'

class SwapItemsOnPendingOrders
  include Sidekiq::Worker
  include JobLogger

  def perform
    Order.where(state: "pending", locked: false).each do |order|
      ScheduledTasks::SwapItemsOnOrderByIdWorker.perform_async(order.id)
    end
  end
  
end
