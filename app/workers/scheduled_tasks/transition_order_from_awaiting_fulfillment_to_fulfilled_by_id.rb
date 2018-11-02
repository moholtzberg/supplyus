module ScheduledTasks
  
  require 'sidekiq-scheduler'

  class TransitionOrderFromAwaitingFulfillmentToFulfilledById
    include Sidekiq::Worker
    include JobLogger

    def perform(order_id)
      puts order_id
      order = Order.find_by(:id => order_id)
      if (order.quantity == order.quantity_shipped) and (order.quantity != order.quantity_fulfilled) and order.account_id.present?
        
        line_count = order.quantity
        price_match_count = 0
        order.order_line_items.each do |line|
          
          if line.price.to_s == line.item.actual_price(order.account_id, line.actual_quantity).to_s
            price_match_count = (price_match_count + line.actual_quantity)
          end
          
        end
        
        if line_count == price_match_count and (order.bill_to_email.present? and order.bill_to_address_1.present?)
          
            Order.transaction do
              if order.create_full_invoice
                OrderMailer.invoice_notification(order.id).deliver_later
              end
            end
          
        else
          order.add_billing_exception
        end
        
      else
        puts "we cannot proceed #{order.number}"
      end
    
    end
  
  end
  
end