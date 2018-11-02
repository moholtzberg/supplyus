class FlaggedOrderLineItem < ActiveRecord::Base
  
  belongs_to :order_line_item
  # belongs_to :order, through: :order_line_item
  belongs_to :appliable, polymorphic: true
  
  after_update :update_order_line_item
  
  def update_order_line_item
    if review_state == "rejected"
      order_line_item.update_attributes(quantity_canceled: order_line_item.quantity)
    end
  end
  
end
