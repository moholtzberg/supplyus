class CreateBudgetCycleOrders < ActiveRecord::Migration
  def change
    create_table :budget_cycle_orders do |t|
      t.integer  :budget_cycle_id
      t.integer  :order_id
      t.decimal  :amount
      t.timestamps
    end
  end
end