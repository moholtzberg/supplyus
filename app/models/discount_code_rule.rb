class DiscountCodeRule < ActiveRecord::Base
  include ApplicationHelper
  attr_accessor :requirable_term
  
  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id
  belongs_to :requirable, polymorphic: true
  validate :amount_or_quantity
  validates :discount_code_id, presence: true

  REQUIRABLE_TYPES = ['Item', 'Category']

  def check(order)
    items = order.order_line_items
    if requirable
      items = requirable_type == 'Item' ? items.by_item(requirable_id) : items.by_category(requirable_id)
    end
    amount_sum = items.sum("(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) * price").to_f
    quantity_sum = items.sum("(COALESCE(quantity,0) - COALESCE(quantity_canceled,0))").to_f
    amount_sum >= amount.to_f && quantity_sum >= quantity.to_f
  end

  def amount_or_quantity
    !(amount && quantity)
  end

  def error_message
    "Order should contain at least #{amount ? '$' + amount.to_s + ' worth of ' : quantity.to_s + ' ' }#{'\'' + requirable.name + '\' ' if requirable}items"
  end
end