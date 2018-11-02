require 'sidekiq-scheduler'

class PurgeIncompleteOrders  
  include Sidekiq::Worker
  include JobLogger

  def perform(days_old)
    puts days_old
    Order.where("state = ? AND updated_at < ?", "incomplete", days_old.days.ago).each do |order|
      if order.quantity_shipped == 0 and order.quantity_fulfilled == 0
        order.destroy
      end
    end
  end
  
end
