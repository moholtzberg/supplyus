class DiscountCodeRule < ActiveRecord::Base
  include ApplicationHelper
  include ActionView::Helpers
  attr_accessor :requirable_term

  belongs_to :discount_code
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

  def error_message(order)
    msg = ''
    msg += 'Code is valid only to specified group of users. ' if (user_appliable && !appliable?(order))
    if amount || quantity
      msg += 'Order must contain at least '
      msg += amount ? "#{number_to_currency(amount)} worth of " : "#{quantity} "
      msg += "\'#{requirable&.name}\' " if requirable
      msg += 'items.'
    end
    msg
  end
  
  def description
    msg = ""
    msg += "Code is valid only for \'#{user_appliable&.name}\' " if user_appliable
    if amount || quantity
      msg += "Order must contain at least "
      msg += amount ? "#{number_to_currency(amount)} worth of " : "#{quantity} "
      msg += "\'#{requirable&.name}\' " if requirable
      msg += "items."
    end
    msg
  end
end
