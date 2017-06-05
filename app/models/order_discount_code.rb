class OrderDiscountCode < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :order
  belongs_to :discount_code

  validates :order_id, presence: true, uniqueness: { scope: :discount_code_id }
  validates :discount_code_id, presence: true
end