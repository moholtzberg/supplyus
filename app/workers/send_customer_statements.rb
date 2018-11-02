require 'sidekiq-scheduler'

class SendCustomerStatements  
  include Sidekiq::Worker
  include JobLogger

  def perform
    Customer.where(active: true).each do |customer|
      if customer.outstanding_invoices > 0
        ScheduledTasks::SendCustomerStatementsByAccountId.perform_async(customer.id)
      end
    end
  end
  
end
