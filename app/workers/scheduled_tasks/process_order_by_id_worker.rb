module ScheduledTasks
  
  require 'sidekiq-scheduler'

  class ProcessOrderByIdWorker
    include Sidekiq::Worker
    include JobLogger

    def perform(order_id)
      puts "------> #{order_id} <----"
      order = Order.find(order_id)
      line_items = []
      order.order_line_items.each_with_index do |line_item,idx|
        qty_for = PurchaseOrderLineItem.where(:order_line_item_id => line_item.id).map(&:quantity).sum
        if qty_for < line_item.actual_quantity
          line_items << line_item
        end
      end
      puts line_items.inspect
      vendors = []
      bucket = []
      line_items.each_with_index do |li, idex|
        vendor_ids = li.item.item_vendor_prices.select(:vendor_id).distinct
        vendor_ids.each do |vend|
          v = ItemVendorPrice.where(vendor_id: vend.vendor_id, item_id: li.item_id).order(:created_at => :desc).limit(1).first
          vendors << vend.vendor_id
          vendor_shipping = AccountShippingMethod.find_by(account_id: vend.id)&.shipping_method&.calculate
          bucket << {vendor_id: vend.vendor_id, item_id: li.item_id, price: v.price, likely_price: v.price_with_shipping_for(li.actual_quantity)}
        end
      end
      puts bucket.inspect
      vendors.uniq!
      puts vendors.inspect
      pos = []
      pols = []
      vendors.each do |vendor|
        po = PurchaseOrder.new(vendor_id: vendor)
        pos << {vendor_id: vendor, po: po}
      end
      line_items.each_with_index do |line, index|
        puts "40 - ------------------ #{index} - #{line.item.number}"
        prices = bucket.map {|lip| lip[:likely_price] if lip[:item_id] == line.item_id}
        puts "42 - #{prices.inspect}"
        prices.compact!
        puts "43 ----------- #{prices.inspect}"
        po_item = bucket.map {|lip| lip[:vendor_id] if lip[:item_id] == line.item_id and lip[:likely_price] == prices.min}
        puts "44 - #{po_item.inspect}"
        po_item.compact!
        puts "46 - #{po_item.inspect}"
        po_order = pos.map {|po| po[:po] if po[:vendor_id] == po_item[0]}
        puts "48 - #{po_order.inspect}"
        po_order.compact!
        puts "50 - #{po_order.inspect}"
        pol = po_order[0].purchase_order_line_items.build
        pol.item_id = line.item_id
        pol.quantity = line.actual_quantity
        pol.price = ItemVendorPrice.last_from_vendor_by_item(line.item_id).where(vendor_id: po_order[0].vendor_id).first.price
        pol.order_line_item_id = line.id
        pol.purchase_order_line_number = index + 1
        pols << pol
        puts "54 - #{pol.inspect}"
      end
      puts "56 - #{pols.inspect}"
      pors = []
      pos.each do |po|
        por = po[:po]
        if por.purchase_order_line_items.any?
          por.notes = order.number
          por.ship_to_account_name = order.ship_to_account_name
          por.ship_to_attention = order.ship_to_attention
          por.ship_to_address_1 = order.ship_to_address_1
          por.ship_to_address_2 = order.ship_to_address_2
          por.ship_to_city = order.ship_to_city
          por.ship_to_state = order.ship_to_state
          por.ship_to_zip = order.ship_to_zip
          por.ship_to_phone = order.ship_to_phone
          vend = Vendor.find(por.vendor_id)
          por.ship_from_vendor_name = vend.name
          por.ship_from_address_1 = vend.address_1
          por.ship_from_address_2 = vend.address_2
          por.ship_from_city = vend.city
          por.ship_from_state = vend.state
          por.ship_from_zip = vend.zip
          por.ship_from_phone = vend.phone
          por.completed_at = DateTime.now
          por.shipping_method = AccountShippingMethod.find_by(account_id: vend.id)&.shipping_method_id
          por.shipping_amount = por.purchase_order_shipping_method&.shipping_method&.calculate(por.sub_total)
          por.save!
          order.update_columns(state: "processing")
          pors << por
        end
      end
      
    end
    
  end
  
end