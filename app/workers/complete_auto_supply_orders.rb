require 'sidekiq-scheduler'

class CompleteAutoSupplyOrders
  include Sidekiq::Worker
  include JobLogger

  def perform
    add_log '********* Completeting Incomplete Toner Orders from Alerts *********'
    orders = Order.not_submitted.where(:notes => 'Auto Supply Order')
    orders.each do |ord|
      ord.update_attributes(:submitted_at => DateTime.now)
      add_log "Order #{ord.number}: success"
    end
    add_log '********* END *********'
  end
end
