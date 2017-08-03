require 'sidekiq-scheduler'

class CompleteAutoSupplyOrders
  
  include Sidekiq::Worker
  
  def perform()
    j = Job.new
    puts "********* Completeting Incomplete Toner Orders from Alerts *********"
    j.job_name = "Complete Incomplete Toner Orders from Alerts"
    orders = Order.not_submitted.where(:notes => "Auto Supply Order")
    orders.each do |ord|
      ord.update_attributes(:submitted_at => DateTime.now)
      j.notes = "Sucess"
    end
    puts "********* END *********"
    j.save
  end
  
end