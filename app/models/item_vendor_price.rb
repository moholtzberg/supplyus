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
  
  def price_with_shipping_for(qty)
    po = PurchaseOrder.new
    pol = po.purchase_order_line_items.build
    pol.item_id = self.id
    pol.quantity = qty
    pol.price = self.price
    po.shipping_method = AccountShippingMethod.find_by(account_id: self.vendor_id)&.shipping_method_id
    puts AccountShippingMethod.find_by(account_id: self.vendor_id).inspect
    puts AccountShippingMethod.find_by(account_id: self.vendor_id)&.shipping_method_id
    po.shipping_amount = po.purchase_order_shipping_method&.shipping_method&.calculate(po.sub_total)
    return po.total
  end
  
  def self.last_from_vendor_by_item(item)
    vendors = ItemVendorPrice.where(item_id: item).select(:vendor_id).distinct.pluck(:vendor_id)
    ivp_ids = []
    vendors.each do |v|
      ivp_ids << ItemVendorPrice.where(item_id: item, vendor_id: v).order(:created_at)&.last&.id
    end
    where(id: ivp_ids).order(:created_at)
  end
  
end
