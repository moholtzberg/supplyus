# every "*/1 * * * *" do # Many shortcuts available: :hour, :day, :month, :year, :reboot
#   runner "HourlyWorker.perform"
#   command "echo 'you can use raw cron syntax too'"
#   runner "puts from the schedule.rb"
# end
# 
require 'rufus/scheduler'
# 
scheduler = Rufus::Scheduler.new

# scheduler.every '1s' do
# scheduler.every '1m' do
# scheduler.every '1h' do
# scheduler.every '1d' do
# scheduler.every '1s' do
# 
scheduler.every '30m' do
  puts "--- FROM THE RUFUS"
  puts "--- #{PaymentPlan.starts_today.count}"
  puts "--- #{PaymentPlan.bill_date_passed.count}"
  PaymentPlan.bill_date_passed.each {|p| puts "----> #{p.next_bill_date}"}
end

# scheduler.every '2m' do
#   puts 'Hello... Rubu'
# end

# scheduler.join