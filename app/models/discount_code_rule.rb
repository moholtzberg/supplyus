class DiscountCodeRule < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :discount_code

end