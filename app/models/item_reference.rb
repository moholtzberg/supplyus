class ItemReference < ActiveRecord::Base
  
  belongs_to :original_item, :class_name => "Item"
  belongs_to :replacement_item, :class_name => "Item"
  
end