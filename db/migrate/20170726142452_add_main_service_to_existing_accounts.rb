class AddMainServiceToExistingAccounts < ActiveRecord::Migration
  def change
    Account.where.not(id: Account.joins(:account_payment_services).pluck(:id)).each do |account|
      account.set_payment_services
      account.save
    end
  end
end
