class BudgetCycle < ActiveRecord::Base
  
  belongs_to :budget
  has_many :budget_cycle_orders
  
  before_validation :calculate_remaining_amount, on: [:create, :update]
  
  def calculate_remaining_amount
    self.remaining_amount = budget.amount.to_d - budget_cycle_orders.map {|o| o.orders.total }.sum.to_d
  end
  
end