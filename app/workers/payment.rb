# namespace :payment do
#   desc "send and generate bills and invoices for today"
#   task generate_for_today: [:environment] do
#   #   today = Date.today
#   #   Account.billable_on(today).with_billing_day(today.day).each do |account|
#   #     Receipt.generate(account, today - 1.day).process_async!
#   #   end
#   puts "hello world"
#   end
# end
class HourlyWorker
  # include Sidekiq::Worker

  def perform
    puts "=========================== What a performance!"
  end
end
