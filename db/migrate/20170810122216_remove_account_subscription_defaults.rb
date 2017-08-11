class RemoveAccountSubscriptionDefaults < ActiveRecord::Migration
  def change
    change_column_default(:accounts, :subscription_week_day, nil)
    change_column_default(:accounts, :subscription_month_day, nil)
    change_column_default(:accounts, :subscription_quarter_day, nil)
  end
end
