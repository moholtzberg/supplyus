class ItemList < ActiveRecord::Base
  
  belongs_to :user
  has_many :items, through: :item_item_lists
  
end
