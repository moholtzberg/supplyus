class AddSubscriptionWeekDaySubscriptionMonthDaySubscriptionQuarterDayToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :subscription_week_day, :integer
    add_column :accounts, :subscription_month_day, :integer
    add_column :accounts, :subscription_quarter_day, :integer
  end
end
