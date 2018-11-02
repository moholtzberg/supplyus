class CreateBudgetCycles < ActiveRecord::Migration
  def change
    create_table :budget_cycles do |t|
      t.integer  :budget_id
      t.decimal  :remaining_amount
      t.date     :start_date
      t.date     :end_date
      t.datetime :created_at
    end
  end
end