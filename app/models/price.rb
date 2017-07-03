class Price < ActiveRecord::Base

  PRICE_TYPES = ['Default', 'Sale', 'Bulk', 'Recurring']

  belongs_to :item

  validates :_type, presence: true, inclusion: { in: PRICE_TYPES }
  
end