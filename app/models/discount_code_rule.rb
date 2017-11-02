class DiscountCodeRule < ActiveRecord::Base
  include ApplicationHelper
  attr_accessor :requirable_term

  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id
  belongs_to :requirable, polymorphic: true
  belongs_to :user_appliable, polymorphic: true
  validate :amount_or_quantity
  validates :discount_code_id, presence: true

  REQUIRABLE_TYPES = %w[Item Category]
  USER_APPLIABLE_TYPES = %w[Account Group]

  def check(order)
    return false unless appliable?(order)
    return false unless enough_items?(order.order_line_items)
    true
  end

  def appliable?(order)
    [order.account, order.account&.group, nil].include?(user_appliable)
  end

  def enough_items?(items)
    if requirable
      items = items.send("by_#{requirable_type.downcase}".to_sym, requirable_id)
    end
    return items.total_price >= amount if amount
    return items.total_qty >= quantity if quantity
    true
  end

  def amount_or_quantity
    !(amount && quantity)
  end

  def error_message
    msg = 'Code is valid only to specified group of users. ' if user_appliable
    if amount || quantity
      msg += 'Order should contain at least '
      msg += amount ? "$#{amount} worth of " : "#{quantity} "
      msg += "\'#{requirable&.name}\' " if requirable
      msg += 'items.'
    end
    msg
  end
end
