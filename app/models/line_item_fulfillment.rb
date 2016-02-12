class LineItemFulfillment < ActiveRecord::Base
  
  belongs_to :order_line_item
  belongs_to :order
  
end