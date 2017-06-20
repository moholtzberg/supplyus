require 'sidekiq-scheduler'

class PaymentWorker  
  
  include Sidekiq::Worker

  def perform
    today = Date.today
    Account.billable_on(today).with_billing_day(today.day).each do |account|
      Receipt.generate(account, today - 1.day).process_async!
    end
  end
end
