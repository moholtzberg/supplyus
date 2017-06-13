class DiscountCodeEffect < ActiveRecord::Base
  include ApplicationHelper
  attr_accessor :appliable_term, :item_term
  
  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id
  belongs_to :appliable, polymorphic: true
  belongs_to :item
  validates :discount_code_id, presence: true, uniqueness: true

  APPLIABLE_TYPES = ['Item', 'Category']

  def calculate(order)
    if amount
      return amount
    elsif shipping
      return (percent/100)*order.shipping_total_sum
    else
      items = order.order_line_items
      if appliable
        items = appliable_type == 'Item' ? items.by_item(appliable_id) : items.by_category(appliable_id)
      end
      amount_sum = items.sum("(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) * price").to_f
      return (percent/100)*amount_sum
    end
  end

  def self.lookup(word)
    where("lower(name) like ?", "%#{word.downcase}%")
  end
end