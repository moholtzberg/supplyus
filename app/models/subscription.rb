class Subscription < ActiveRecord::Base
    
  belongs_to :address
  belongs_to :item

  validates :quantity, :presence => true
  validates :frequency, :presence => true
  
end