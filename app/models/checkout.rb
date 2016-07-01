class Checkout < Order
  
  validates :ship_to_account_name, :presence => true
  validates :ship_to_address_1, :presence => true
  validates :ship_to_city, :presence => true
  validates :ship_to_state, :presence => true
  validates :ship_to_zip, :presence => true
  validates :email, :presence => true
  
  has_one :order_shipping_method, :foreign_key => :order_id
  # has_one :shipping_method, :through => :order_shipping_method
  
  def complete
    completed_at.nil? ? false : true
  end
  
end