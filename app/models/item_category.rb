class ItemCategory < ActiveRecord::Base
  
  belongs_to :category
  belongs_to :item
  
  def category_name
    category.try(:name)
  end
  
  def category_name=(name)
    self.category = Category.find_by(:name => name) if name.present?
  end
  
end