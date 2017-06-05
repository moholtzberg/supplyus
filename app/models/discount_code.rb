class DiscountCode < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :orders, through: :order_discount_codes
  has_many :rules, class_name: 'DiscountCodeRule'
  has_one :effect, class_name: 'DiscountCodeEffect'

  validates :code, presence: true, uniqueness: true
  validates :times_of_use, presence: true
end