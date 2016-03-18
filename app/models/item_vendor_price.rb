class ItemVendorPrice < ActiveRecord::Base
  
  belongs_to :vendor
  belongs_to :item
  
  def item_number
   item.try(:number)
  end

  def item_number=(number)
   self.item = Item.find_by(:number => number) if number.present?
  end

  def vendor_name
   vendor.try(:name)
  end

  def vendor_name=(name)
   self.vendor = Vendor.find_by(:name => name) if name.present?
  end
  
end
