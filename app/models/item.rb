class Item < ActiveRecord::Base
  
  has_many :account_item_prices
  has_many :images
  # has_attached_file :image, styles: {
  #   thumb: '100x100>',
  #   square: '200x200#',
  #   medium: '400x400>'
  # }
  has_many :order_line_items
  belongs_to :category
  belongs_to :brand
  belongs_to :model
  
  validates_uniqueness_of :number
  # validates_uniqueness_of :slug
  
  before_validation :slugger
  
  def brand_name
    brand.try(:name)
  end
  
  def brand_name=(name)
    self.brand = Brand.find_by(:name => name) if name.present?
  end
  
  def self.search(word)
    includes(:brand).where("lower(number) like ? or lower(items.name) like ? or lower(description) like ? or lower(brands.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:brand)
  end
  
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
      puts "----> #{images.first.path}"
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
    # total = 0.0
    # OrderLineItem.joins(:item).where(:item_id => id).each {|o| total += o.quantity.to_i}
    # total
    OrderLineItem.where(item_id: id).sum(:quantity)
  end
  
  def self.times_ordered
    Item.joins(:order_line_items).group(:item_id).sort_by(&:times_purchased).reverse!
    # Item.select("items.*, count(order_line_items.quantity) AS times_purchased")
    # .joins("INNER JOIN order_line_items ON order_line_items.quantiy = docs.sourceid")
    #  .group("docs.id")
    # .order("denotations_count DESC")
  end
  
  def import_xml
    AWS.config({
        :access_key_id => "#{SECRET['AWS']['ACCESS_KEY_ID']}",
        :secret_access_key => "#{SECRET['AWS']['SECRET_ACCESS_KEY']}",
    })
    bucket_name = '247officesuppy/400/400'

    s3 = AWS::S3.new()
    bucket = s3.buckets[bucket_name]
    
    begin
      noko = Hash.from_xml(open("#{Rails.root}/app/assets/images/ecdb.individual_items/#{self.number}.xml"))
    rescue
      "No such file #{self.number}.xml"
    else
      info = noko["SyncItemMaster"]["DataArea"]["ItemMaster"]["ItemMasterHeader"]
      brand = info["ManufacturerItemID"]["schemeAgencyName"]
      
      sku_group_image = ""
      info["Classification"].each {|o| if o["type"] == "SKU_Group" then sku_group_image = o["SkuGroupImage"] end }
      single_image = info['DrawingAttachment']['FileName']
      
      if AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{single_image}"].exists?
        
        image = single_image
        puts "----> SINGLE IMAGE = #{image}"
        bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
        
      elsif AWS::S3.new.buckets["247officesuppy"].objects["400/400/#{sku_group_image}"].exists?
        
        image = sku_group_image
        puts "----> SKU GROUP IMAGE = #{image}"
        bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
        
      else
        image = "NOA.JPG"
      end
      
      item_images = self.images
      
      if self.images.count > 1
        (1..self.images.count).each {|im| Image.find_by(id: "im").destroy }
      end
      
      if self.images.count == 1
        Image.find_by(id: self.images.first.id).update_attributes(:attachment_file_name => image)
      else
        Image.create(:attachment_file_name => image)
      end
      
    end
  end
  
end