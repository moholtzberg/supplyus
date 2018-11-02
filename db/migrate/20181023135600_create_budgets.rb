class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string   :name,           :null => false
      t.integer  :budgetable_id,   :null => false
      t.string   :budgetable_type, :limit => 50
      t.integer  :budget_supervisor_id
      t.boolean  :allow_over_budget_ordering, :default => false  
      t.decimal  :amount 
      t.string   :budget_cycle
      t.date     :budget_start
      t.datetime :created_at
    end
  end
end
