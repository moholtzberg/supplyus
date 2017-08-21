class GroupItemPrice < ActiveRecord::Base
  
  belongs_to :group
  belongs_to :item
  
  validates :group_id, :presence => true
  validates :item_id, :presence => true
  validates :price, :presence => true, :numericality => true
  
  scope :by_group, -> (group_id) { where(group_id: group_id)}
  scope :by_item, -> (item_id) { where(item_id: item_id)}
  
  scope :order_by_item, -> () { order(:item_id => :asc)}
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(number)
    self.item = Item.find_by(:number => number) if number.present?
  end
  
  def group_name
    group.try(:name)
  end
  
  def group_name=(name)
    self.group = Group.find_by(:name => name) if name.present?
  end
  
  def copy_from=(group)
    Group.find_by(:name => group) if group.present?
  end
  
  def copy_from
  end
  
end
