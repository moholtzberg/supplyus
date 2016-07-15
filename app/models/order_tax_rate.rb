class OrderTaxRate < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :tax_rate
  validates :order, :uniqueness => true
  
  delegate :name, :to => :tax_rate
  
  def calculate
    unless tax_rate.nil?
      effective_rate = tax_rate.rate
    else
      effective_rate = 0.0
    end
    return order.sub_total * effective_rate
  end
  
end