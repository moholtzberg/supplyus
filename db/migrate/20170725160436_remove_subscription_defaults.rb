class RemoveSubscriptionDefaults < ActiveRecord::Migration

  def self.up
    change_column :accounts, :subscription_week_day, :integer
    change_column :accounts, :subscription_month_day, :integer
    change_column :accounts, :subscription_quarter_day, :integer
    Account.where.not(id: Subscription.pluck(:account_id).uniq).update_all(subscription_week_day: nil, subscription_month_day: nil, subscription_quarter_day: nil)
  end
  
  def self.down
    change_column :accounts, :subscription_week_day, :integer, default: 1
    change_column :accounts, :subscription_month_day, :integer, default: 1
    change_column :accounts, :subscription_quarter_day, :integer, default: 1
    Account.where.not(id: Subscription.pluck(:account_id).uniq).update_all(subscription_week_day: 1, subscription_month_day: 1, subscription_quarter_day: 1)
  end
  
end
