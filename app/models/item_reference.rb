class ItemReference < ActiveRecord::Base
  
  belongs_to :original_item, :class_name => "Item"
  belongs_to :replacement_item, :class_name => "Item"
  
  def original_item_number
    original_item.try(:number)
  end
  
  def original_item_number=(number)
    self.original_item = Item.find_by(:number => number) if number.present?
  end
  
  def replacement_item_number
    replacement_item.try(:number)
  end
  
  def replacement_item_number=(number)
    self.replacement_item = Item.find_by(:number => number) if number.present?
  end
  
end