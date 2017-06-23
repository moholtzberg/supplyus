class PurchaseOrder < ActiveRecord::Base
  
  include ApplicationHelper
  
  belongs_to :vendor, :class_name => "Account"
  has_many :purchase_order_line_items, :inverse_of => :purchase_order, :dependent => :destroy
  has_many :purchase_order_receipts, :dependent => :destroy
  has_one :purchase_order_shipping_method, :dependent => :destroy, :inverse_of => :purchase_order
  
  before_save :make_record_number

  def shipping_method
    purchase_order_shipping_method.try(:shipping_method_id)
  end
  
  def shipping_method=(method)
    purchase_order_shipping_method = PurchaseOrderShippingMethod.find_or_create_by(:purchase_order_id => id) if method.present?
    puts purchase_order_shipping_method.inspect
    purchase_order_shipping_method.shipping_method_id = method if method.present?
    purchase_order_shipping_method.save
  end
  
  def shipping_amount
    purchase_order_shipping_method.try(:amount)
  end
  
  def shipping_amount=(name)
    purchase_order_shipping_method.amount = name if name.present?
    purchase_order_shipping_method.save
  end
  
  def sub_total
    purchase_order_line_items.map(&:sub_total).sum
  end
  
  def shipping_total
    purchase_order_shipping_method.amount unless purchase_order_shipping_method.nil?
  end
  
  def total
    sub_total + shipping_total.to_f.to_d
  end
  
  def quantity
    purchase_order_line_items.map(&:quantity).sum
  end
  
  def amount_received
    purchase_order_line_items.map(&:amount_received).sum
  end
  
  def quantity_received
    purchase_order_line_items.map(&:quantity_received).sum
  end
  
  def received
    quantity_received == quantity
  end
  
  def make_record_number
    if number.blank?
      last_record = self.class.unscoped.last
      if last_record.nil? or last_record.number.nil?
        record_number = "10000"
      else
        record_number = last_record.number
      end
      record_number = get_number_from_record_number(record_number)
      record_number = record_number.next
      if self.class.find_by(:number => record_number)
        record_number = record_number.next
      end
      self.number = "PO#{record_number.to_i}"
    end
  end
  
end
