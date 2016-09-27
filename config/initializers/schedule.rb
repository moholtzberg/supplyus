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
  # puts "--- #{PaymentPlan.starts_today.count}"
  # puts "--- #{PaymentPlan.bill_date_passed.count}"
  # PaymentPlan.bill_date_passed.each {|p| puts "----> #{p.next_bill_date}"}
end

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

# scheduler.join