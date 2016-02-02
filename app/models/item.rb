class Item < ActiveRecord::Base
  
  has_many :account_item_prices
  has_many :images
  belongs_to :category
  
  validates_uniqueness_of :number
  validates_uniqueness_of :slug
  
  before_validation :slugger
  
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
  
  def slugger
    puts "we slugging it out"
    if self.slug.nil?
      puts "NO SLUG"
      puts "---> #{self.slug}"
      puts "---> #{self.name}"
      self.slug = name.downcase.tr(" ", "-") unless self.name.nil?
      puts "---> #{self.inspect}"
    else
      puts "---> #{self.slug}"
    end
  end
  
end