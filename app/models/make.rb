class Make < ActiveRecord::Base
  
  has_many :models
  
  default_scope { order(:name) }
  
end
