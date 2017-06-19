class ItemList < ActiveRecord::Base
  
  belongs_to :user
  has_many :items, through: :item_item_lists
  has_many :item_item_lists, dependent: :destroy
  accepts_nested_attributes_for :item_item_lists
  
end
