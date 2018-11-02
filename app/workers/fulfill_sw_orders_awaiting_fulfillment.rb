require 'sidekiq-scheduler'

class FulfillSwOrdersAwaitingFulfillment
  include Sidekiq::Worker
  include JobLogger

  def perform
    group = Group.find(5)
    account_ids = group.accounts.ids
    limit = 1
    orders = Order.where(account_id: account_ids, state: "awaiting_fulfillment").limit(limit)
    orders.each do |ord|
      #######==============================#########
      
      
      order = Order.find_by(:id => ord.id)
      if (order.quantity == order.quantity_shipped) and (order.quantity != order.quantity_fulfilled) and order.account_id.present?
        
        line_count = order.quantity
        price_match_count = 0
        order.order_line_items.each do |line|
          
          order_pool = Order.where(account_id: account_ids, state: ["fulfilled", "completed"]).ids
          price = OrderLineItem.where(order_id: order_pool, item_id: line.item_id).order(:id).last&.price
          line.price = price if (!price.nil? or !price.blank? or !price == 0)
          # line_good = false
          
          # case
          # when line.price == line.item.actual_price(order.account_id, line.actual_quantity)
          #   line_good = true
          # when line.price == price
          #   line_good = true
          # when (line.price.nil? or line.price.blank? or line.price == 0)
          # else
          # end
          
          if line.price != line.item.actual_price(order.account_id, line.actual_quantity) or line.price != price or line.price == 0
            puts  "-X #{order.number}:#{line.order_line_number} - #{line.item.number} - #{line.price}"
            line.update_attribute(:description, "Price Check - Remove This Comment When Done.")
          else
            puts "-> #{order.number}:#{line.order_line_number} - #{line.item.number} - #{line.price} / #{line.item.actual_price(order.account_id, line.actual_quantity)} / #{price}"
            price_match_count = (price_match_count + line.actual_quantity)
          end
          
          puts "--> #{line_count}:#{price_match_count}"
        end
        
        if line_count == price_match_count and (order.bill_to_email.present? and order.bill_to_address_1.present?)
          
            # Order.transaction do
            #   if order.create_full_invoice
            #     OrderMailer.invoice_notification(order.id).deliver_later
            #   end
            # end
          
        else
          order.add_billing_exception
        end
        
      else
        puts "we cannot proceed #{order.number}"
      end
      
      
      #######==============================#########
    end
  end

end