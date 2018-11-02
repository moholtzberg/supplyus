module ScheduledTasks
  
  require 'sidekiq-scheduler'

  class SendCustomerStatementsByAccountId
    include Sidekiq::Worker
    include JobLogger

    def perform(customer_id)
      customer = Customer.find(customer_id)
      str_date = (customer.orders.order(:submitted_at).first.submitted_at - 90.days).strftime("%m/%d/%y")
      end_date = Date.today.strftime("%m/%d/%y")
      AccountMailer.statement_notification(customer.id, str_date, end_date, :to => customer.bill_to_email).deliver_later
    end
  
  end
  
end