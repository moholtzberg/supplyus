class DiscountCodeRule < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :code, class_name: 'DiscountCode', foreign_key: :discount_code_id

  def check
    true
  end
end