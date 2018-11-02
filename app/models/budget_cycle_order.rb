class BudgetCycleOrder < ActiveRecord::Base
  
  belongs_to :budget_cycle, touch: true
  belongs_to :order
  
end