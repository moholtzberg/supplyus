class OrderDiscountCode < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :order
  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id

  validates :order_id, presence: true, uniqueness: { scope: :discount_code_id }
  validates :discount_code_id, presence: true
  validate :check_rules

  after_create :apply_effect
  after_destroy :remove_effect

  def check_rules
    code.rules.each do |rule|
      errors.add(:order, rule.error_message) if !rule.check(order)
    end
  end

  def apply_effect
    #line item is added here too
    discount = code.effect.calculate(order)
    order.update_attribute(:discount_total, order.discount_total + discount)
  end

  def remove_effect
    discount = code.effect.calculate(order)
    order.update_attribute(:discount_total, order.discount_total - discount)
  end
end