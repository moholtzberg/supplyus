class Budget < ActiveRecord::Base
  
  belongs_to :budgetable, polymorphic: true
  has_many :budget_cycles
  
  def current_cycle
    budget_cycles.where("start_data <= ? and end_date >= ?", Date.today, Date.today).limit(1).first
  end
  
end