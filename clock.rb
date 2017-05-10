require 'clockwork'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  
  handler do |job|
    case job
    when "test"
      TestWorker::perform_async
    when "order_line_item_from_equipment_alert"
      OrderLineItemFromEquipnentAlert::perform_async
    when "complete_incomplete_auto_supply_orders"
      CompleteIncompleteAutoSupplyOrders::perform_async
    else
      puts "No suitbale jobs to run"
    end
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end
  every(5.seconds, 'lorem')
  every(20.seconds, 'test')
  every(1.hour, 'order_line_item_from_equipment_alert', :at => '**:30')
  every(1.day, 'complete_incomplete_auto_supply_orders', :at => '16:00')
  
end