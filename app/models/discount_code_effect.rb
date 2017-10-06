class DiscountCodeEffect < ActiveRecord::Base
  include ApplicationHelper
  attr_accessor :appliable_term, :item_term

  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id
  belongs_to :appliable, polymorphic: true
  belongs_to :item
  validates :code, presence: true, uniqueness: true

  after_save :recalculate_discounts

  APPLIABLE_TYPES = ['Item', 'Category']

  def self.lookup(word)
    where('lower(name) like ?', "%#{word.downcase}%")
  end

  def calculate(order)
    return amount if amount
    return (percent / 100) * order.shipping_total_sum if shipping
    appliable_items(order)
      .sum('(COALESCE(quantity,0) - COALESCE(quantity_canceled,0)) * price')
      .to_f * (percent / 100)
  end

  def appliable_items(order)
    items = order.order_line_items
    return items unless appliable
    items.send("by_#{appliable_type.downcase}", appliable_id)
  end

  def recalculate_discounts
    code.order_discount_codes.each(&:apply_effect)
  end
end
