class DiscountCode < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :discount_code

end