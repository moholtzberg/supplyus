class ReturnAuthorization < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :customer
  
  def customer_name
    customer.try(:name)
  end
  
  def customer_name=(name)
    self.customer = Customer.find_by(:name => name) if name.present?
  end
  
  def order_number
    order.try(:number)
  end
  
  def order_number=(number)
    self.order = Order.find_by(:number => number) if number.present?
  end
  
end