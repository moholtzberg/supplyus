class DiscountCode < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :orders, through: :order_discount_codes
  has_many :order_discount_codes
  has_many :rules, class_name: 'DiscountCodeRule'
  has_one :effect, class_name: 'DiscountCodeEffect'
  delegate :name, to: :effect, allow_nil: true

  validates :code, presence: true, uniqueness: true
  validates :times_of_use, presence: true

  def remaining
    times_of_use - order_discount_codes.size
  end

  def self.lookup(word)
    includes(:effect).where("lower(code) like ? or lower(discount_code_effects.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%").references(:effect)
  end
end