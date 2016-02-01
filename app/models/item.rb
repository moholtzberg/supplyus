class Item < ActiveRecord::Base
  
  has_many :account_item_prices
  has_many :images
  belongs_to :category
  
  scope :search, -> (keywords) { where("number like ? or name like ? or description like ?", "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")}
  
  def actual_price(account_id={})
    unless account_id.blank?
      unless self.account_item_prices.by_account(account_id).blank? 
        return self.account_item_prices.by_account(account_id).last.price
      else
        return price
      end
      return price
    end
  end
  
  def default_image_path
    unless images.first.nil?
      images.first.path
    end
  end
  
end