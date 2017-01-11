require 'rufus/scheduler'

if "#{SECRET['RUN_JOBS']}".present? and "#{SECRET['RUN_JOBS']}" == "true"

  scheduler = Rufus::Scheduler.new

  # scheduler.every '1s' do
  # scheduler.every '1m' do
  # scheduler.every '1h' do
  # scheduler.every '1d' do
  # scheduler.every '1s' do
  
  # scheduler.every '30m' do
    # puts "--- FROM THE RUFUS"
    # puts "--- #{PaymentPlan.starts_today.count}"
    # puts "--- #{PaymentPlan.bill_date_passed.count}"
    # PaymentPlan.bill_date_passed.each {|p| puts "----> #{p.next_bill_date}"}
  # end
  
  # scheduler.every '1d' do
  #   # puts 'Hello... Rubu'
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
  
  scheduler.every '15s' do
    puts "RUNNING A JOB"
  end
  
  scheduler.every '1h' do
    puts "********* Crating Orders from Equipment Alerts *********"
    alerts = EquipmentAlert.where(:active => true, :alert_type => "start", :order_line_item_id => nil)
    alerts.each do |alert|
      if alert.equipment_id
        equipment = alert.equipment
        order = Order.where(:locked => nil, :completed_at => nil, :customer => equipment.account_id).first
        puts order.inspect
        if order.nil?
          order = Order.new(:customer => equipment.customer)
          puts order.inspect
        end
        puts order.inspect
        order.notes = "Auto Supply Order"
        supply = equipment.find_supply(alert.supply_type, alert.supply_color)
        unless supply.nil?
          line = order.order_line_items.new
          line.item_id = supply.item_id
          line.quantity = 1
          line.description = "ID# #{equipment.number} / #{equipment.location}"
          line.price = line.item.get_lowest_price(equipment.account_id)
          if line.save
            alert.update_attributes(:active => false, :order_line_item_id => line.id)
          end
        end
      end
    end
    puts "********* END *********"
  end

# scheduler.join
end 