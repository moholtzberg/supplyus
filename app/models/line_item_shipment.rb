class LineItemShipment < ActiveRecord::Base
  
  belongs_to :order_line_item, :touch => true
  belongs_to :shipment, :touch => true
  
  after_commit :flush_cache
  
  def flush_cache
    Rails.cache.delete("open_orders")
  end
  
end