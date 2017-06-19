class ItemItemList < ActiveRecord::Base
  
  belongs_to :item
  belongs_to :item_list
  validates :item_list_id, uniqueness: { scope: :item_id }
  
end
