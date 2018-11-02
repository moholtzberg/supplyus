class DiscountCode < ActiveRecord::Base
  include ApplicationHelper

  has_many :orders, through: :order_discount_codes
  has_many :order_discount_codes, :inverse_of => :discount_code
  has_many :discount_code_rules
  has_one :discount_code_effect, dependent: :destroy
  delegate :name, to: :discount_code_effect, allow_nil: true

  validates :code, presence: true, uniqueness: true
  validates :times_of_use, presence: true

  after_create { create_effect }

  def remaining
    times_of_use - order_discount_codes.size
  end

  def self.lookup(word)
    includes(:discount_code_effect)
      .where('lower(code) like ? or lower(discount_code_effects.name) like ?',
             "%#{word.downcase}%", "%#{word.downcase}%").references(:effect)
  end
end
