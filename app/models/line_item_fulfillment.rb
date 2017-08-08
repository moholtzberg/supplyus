class LineItemFulfillment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :order, :foreign_key => :invoice_id, :touch => true
  
  after_save :recalculate_line_item
  
  def recalculate_line_item
    self.order_line_item.update_shipped_fulfilled
  end
  
end