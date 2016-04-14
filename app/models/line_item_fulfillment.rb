class LineItemFulfillment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :order, :foreign_key => :invoice_id, :touch => true
  
  # after_commit :update_fulfilled
  # 
  # def update_fulfilled
  #   quantity_fulfilled = calculate_quantity_fulfilled
  # end
  
end