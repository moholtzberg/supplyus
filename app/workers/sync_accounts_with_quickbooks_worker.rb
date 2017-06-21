class SyncAccountsWithQuickbooksWorker
  include Sidekiq::Worker
  
  def perform()
    last_updated_account_id = Setting.find_or_create_by(:key => "last_updated_account_id")
    start_id = last_updated_account_id.value.to_i
    end_id = start_id + 10
  
    Account.order(:id).where(id: start_id..end_id).each do |cust|
      sleep 1
      puts "#{cust.id} -> #{cust.name}"
      cust.sync_with_quickbooks
      last_updated_account_id.value = cust.id
      last_updated_account_id.save
    end
  end
  
end