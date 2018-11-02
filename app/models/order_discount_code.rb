class OrderDiscountCode < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :order, :inverse_of => :order_discount_code, touch: true
  belongs_to :discount_code, :inverse_of => :order_discount_codes

  # validates :order_id, presence: true, uniqueness: { scope: :discount_code_id }
  validates :order_id, presence: true, uniqueness: true
  # validates :discount_code_id, presence: true
  validate :check_rules, on: [:create, :update]
  validate :times_of_use_limit, on: :create

  # after_create :apply_effect
  # after_save :apply, prepend: true
  # after_destroy :remove_effect
  
  def check_rules
    discount_code&.discount_code_rules&.each do |rule|
      errors.add(:order, rule.error_message(order)) unless rule.check(order)
    end
  end
  
  def apply
    (discount_code&.discount_code_rules&.map {|r| r.check(order)})&.pop ? apply_effect : remove_effect
  end
  
  def apply_effect
    discount = discount_code.discount_code_effect.calculate(order)
    # amount = discount
    self.update_attributes(amount: discount)
  end

  def remove_effect
    # amount = 0
    self.update_attributes(amount: 0)
  end

  def times_of_use_limit
    return if discount_code&.order_discount_codes(:reload)&.count <= discount_code.times_of_use
    errors.add(:order, 'Discount code is exhausted.')
  end
end
