class LineItemFulfillment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :order, :touch => true
  
end