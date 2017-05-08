class CompleteIncompleteAutoSupplyOrders
  include Sidekiq::Worker
  
  def peform()
    j = Job.new
    puts "********* Completeting Incomplete Toner Orders from Alerts *********"
    j.job_name = "Complete Incomplete Toner Orders from Alerts"
    orders = Order.is_incomplete.where(:notes => "Auto Supply Order")
    orders.each do |ord|
      ord.update_attributes(:completed_at => DateTime.now)
      j.notes = "Sucess"
    end
    puts "********* END *********"
    j.save
  end
  
end