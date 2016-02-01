class Item < ActiveRecord::Base
  
  has_many :account_item_prices
  has_many :images
  belongs_to :category
  
  scope :search, -> (keywords) { where("number like ? or name like ? or description like ?", "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")}
  
  def actual_price(account_id={})
    if account_id
      unless AccountItemPrice.by_account(account_id).by_item(id).blank?      
        AccountItemPrice.by_account(account_id).by_item(id).last.price
      else
        price
      end
      price
    end
  end
  
  def default_image_path
    unless images.first.nil?
      images.first.path
    end
  end
  
end