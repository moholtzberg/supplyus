class Item < ActiveRecord::Base
  
  has_many :account_item_prices
  has_many :images
  has_many :order_line_items
  belongs_to :category
  belongs_to :brand
  belongs_to :model
  
  validates_uniqueness_of :number
  # validates_uniqueness_of :slug
  
  before_validation :slugger
  
  scope :search, -> (word) { where("lower(number) like ? or lower(name) like ? or lower(description) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%")}
  
  
  self.per_page = 10
  
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
      self.slug = name.downcase.tr(" ", "-") unless self.name.nil?
      puts "---> #{self.inspect}"
    else
      puts "---> #{self.slug}"
    end
  end
  
  def times_purchased
    total = 0.0
    OrderLineItem.joins(:item).where(:item_id => id).each {|o| total += o.quantity}
    total
  end
  
  def self.times_ordered
    Item.joins(:order_line_items).group(:item_id).sort_by(&:times_purchased).reverse!
    # Item.select("items.*, count(order_line_items.quantity) AS times_purchased")
    # .joins("INNER JOIN order_line_items ON order_line_items.quantiy = docs.sourceid")
    #  .group("docs.id")
    # .order("denotations_count DESC")
  end
  
end