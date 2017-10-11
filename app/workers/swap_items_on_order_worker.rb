require 'sidekiq-scheduler'

class SwapItemsOnOrderWorker  
  include Sidekiq::Worker
  include JobLogger

  def perform(order_id)
    order = Order.find(order_id)
    if order.pending?
      if order.account and order.account.replace_items == true
        order.order_line_items.each do |line_item|
          if line_item.item and (line_item.item.item_substitutes.size > 0)
            subs = line_item.item.item_substitutes
            price_to_beat = line_item.price
            best_match = line_item.item_id
            quantity = line_item.actual_quantity
            add_log "Quantity -> #{quantity}"
            new_best_match = nil
            subs.each do |sub|
              if sub.replacement_item.actual_price(order.account_id) < price_to_beat
                price_to_beat = sub.replacement_item.actual_price(order.account_id)
                new_best_match = sub.replacement_item
                quantity = (sub.original_uom_qty.to_i * line_item.actual_quantity.to_i).to_i / sub.replacement_uom_qty.to_i
                add_log "-> Quantity -> #{quantity}"
                if quantity < 1
                  quantity = 1
                end
              end
            end
            add_log "BestMatch -> #{Item.find(best_match).item_vendor_prices.map(&:price).min}"
            add_log "NewBest Match -> #{new_best_match}"
            if Item.find(new_best_match).actual_cost_price <= Item.find(best_match).actual_cost_price
              line_item.quantity_canceled = line_item.quantity
              new_line_item = order.order_line_items.new(item_id: new_best_match.id, quantity: quantity, price: new_best_match.actual_price(order.account_id))
              add_log "-------> new_line #{new_line_item.inspect}"
              add_log "-------> old_line #{line_item.inspect}"
              line_item.save
              new_line_item.save
            end
          end
        end
      end
    end
  end
end
