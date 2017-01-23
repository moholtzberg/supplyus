require 'rufus/scheduler'

if "#{SECRET['RUN_JOBS']}".present? and "#{SECRET['RUN_JOBS']}" == "true"

  scheduler = Rufus::Scheduler.new

  # scheduler.every '1s' do
  # scheduler.every '1m' do
  # scheduler.every '1h' do
  # scheduler.every '1d' do
  
  # scheduler.every '30m' do
    # puts "--- #{PaymentPlan.starts_today.count}"
    # puts "--- #{PaymentPlan.bill_date_passed.count}"
    # PaymentPlan.bill_date_passed.each {|p| puts "----> #{p.next_bill_date}"}
  # end
  
  # scheduler.every '1d' do
  #   last_updated_account_id = Setting.find_or_create_by(:key => "last_updated_account_id")
  #   start_id = last_updated_account_id.value.to_i
  #   end_id = start_id + 10
  #   Account.order(:id).where(id: start_id..end_id).each do |cust|
  #     sleep 1
  #     puts "#{cust.id} -> #{cust.name}"
  #     cust.sync_with_quickbooks
  #     last_updated_account_id.value = cust.id
  #     last_updated_account_id.save
  #   end
  # end
  
  scheduler.every '15m' do
    puts "RUNNING A JOB"
  end
  
  scheduler.every '1h' do
    j = Job.new
    puts "********* Crating Orders from Equipment Alerts *********"
    j.job_name = "Crating Orders from Equipment Alerts"
    alerts = EquipmentAlert.where(:active => true, :alert_type => "start", :order_line_item_id => nil)
    alerts.each do |alert|
      if alert.equipment_id
        equipment = alert.equipment
        customer = equipment.customer
        order = Order.where(:locked => nil, :completed_at => nil, :customer => equipment.account_id).first
        
        if order.nil?
          order = Order.new(:customer => equipment.customer)
        end
  
        order.notes = "Auto Supply Order"
        order.sales_rep_id = customer.sales_rep_id
        order.ship_to_account_name = customer.name
        order.ship_to_address_1 = customer.ship_to_address_1
        order.ship_to_address_2 = customer.ship_to_address_2
        order.ship_to_city = customer.ship_to_city
        order.ship_to_state = customer.ship_to_state
        order.ship_to_zip = customer.ship_to_zip
        order.email = customer.email
        order.bill_to_account_name = customer.name
        order.bill_to_address_1 = customer.bill_to_address_1
        order.bill_to_address_2 = customer.bill_to_address_2
        order.bill_to_city = customer.bill_to_city
        order.bill_to_state = customer.bill_to_state
        order.bill_to_zip = customer.bill_to_zip
        order.bill_to_email = customer.bill_to_email
        supply = equipment.find_supply(alert.supply_type, alert.supply_color)
        unless supply.nil?
          line = order.order_line_items.new
          line.item_id = supply.item_id
          line.quantity = 1
          line.description = "ID# #{equipment.number} / #{equipment.location}"
          line.price = line.item.get_lowest_price(equipment.account_id)
          if line.save
            alert.update_attributes(:active => false, :order_line_item_id => line.id)
            j.notes = "Sucess"
          end
        end
      end
    end
    puts "********* END *********"
    j.save
  end
  
  scheduler.cron '30 16 * * *' do
    j = Job.new
    puts "********* Completeting Incomplete Toner Orders from Alerts *********"
    j.job_name = "Complete Incomplete Toner Orders from Alerts"
    orders = Order.is_incomplete.where(:notes => "Auto Supply Order").limit(1)
    orders.each do |ord|
      ord.update_attributes(:completed_at => DateTime.now)
      j.notes = "Sucess"
    end
    puts "********* END *********"
    j.save
  end
  
# scheduler.join
end 