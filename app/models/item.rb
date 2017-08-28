class Item < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :active, -> { where(:active => true)}
  scope :inactive, -> { where(:active => false)}
  
  has_many :item_vendor_prices
  has_many :images
  has_many :assets, -> { order(position: :asc) }
  has_many :order_line_items
  has_many :purchase_order_line_items
  has_many :inventory_transactions
  has_many :item_properties, :inverse_of => :item
  has_many :specifications, :class_name => "Specification", :inverse_of => :item
  has_many :features, :class_name => "Feature", :inverse_of => :item
  has_many :properties, :class_name => "Property", :inverse_of => :item
  has_many :item_categories, :inverse_of => :item
  has_many :categories, :through => :item_categories
  has_many :item_substitutes, :class_name => "ItemReference", :foreign_key => :original_item_id
  has_many :substituting_items, :class_name => "ItemReference", :foreign_key => :replacement_item_id
  has_many :item_lists, through: :item_item_lists
  has_many :item_item_lists, dependent: :destroy
  has_many :prices
  belongs_to :category
  belongs_to :brand
  belongs_to :model
  has_many :inventories, :class_name => "Inventory"
  attr_reader :category_tokens
  accepts_nested_attributes_for :prices, allow_destroy: true
  
  validates_uniqueness_of :number
  validate :one_default_price
  # validates_uniqueness_of :slug
  
  before_validation :slugger
  
  searchable do
    text :number, :stored => true, :boost => 4
    text :name, :stored => true, :boost => 2
    text :description, :stored => true
    
    text :brand do
      brand.name if brand
    end
    
    # text :item_categories do
    #   item_categories.map { |item_category| item_category.category.name }
    # end

    text :item_properties do
      item_properties.map { |item_property| item_property.value }
    end
    
    float :actual_price, :trie => true
    
    string :brand, :stored => true do
      brand.name if brand
    end
    
    integer :category_ids, :multiple => true, :references => Category

    string :specs, :multiple => true, :stored => true do
      specifications.map { |spec| "#{spec.key}|#{spec.value}" unless spec.value.blank?}
    end
    
  end
  
  def self.dynamic_facets(orig_facet)
    new_facet = {}
    orig_facet.rows.each do |facet|
      k,v = facet.value.split('|')
      new_facet[k] ||= {}
      new_facet[k][v] ||= 0
      new_facet[k][v] += facet.count
    end
    new_facet
  end
 
  def self.no_images
    Item.includes(:images).where(:assets => {:item_id => nil})
  end
 
  def brand_name
    brand.try(:name)
  end
  
  def brand_name=(name)
    self.brand = Brand.find_by(:name => name) if name.present?
  end
  
  def index_async
    ItemIndexWorker.perform_async(id)
  end
  
  def essendant_xml_import_async
    EssendantXmlImportWorker.perform_async(id)
  end
  
  def category_name
    category.try(:name)
  end
  
  def category_name=(name)
    self.category = Category.find_by(:name => name) if name.present?
  end
  
  def category_tokens=(tokens)
    self.category_ids = tokens.split(",")
  end
  
  def default_category
    if !self.categories.first.nil?
      self.categories.first
    else
      Category.find_or_create_by(:name => "Uncategorized", :slug => "uncategorized")
    end
  end
  
  def self.lookup(word)
    includes(:brand, :categories).where("lower(number) like ? or lower(items.name) like ? or lower(items.description) like ? or lower(brands.name) like ? or lower(categories.name) like ?", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%", "%#{word.downcase}%").references(:brand, :categories)
  end
  
  def self.search_fulltext(word, brand)
    res = Sunspot.search( Item ) do
      fulltext word
    end
    res.results
  end

  def self.render_auto(word)
    res = Sunspot.search( Item ) do
      fulltext word
    end

    occurence = []
    res.results.each do |item|
      it = {}
      it["id"] = item.id
      it["name"] = item.name
      it["number"] = item.number
      it["description"] = item.description
      it["image_path"] = item.default_image_path unless item.images.nil?
      occurence << it
    end
    occurence
  end
  
  self.per_page = 10
  
  def actual_cost_price
    prices = item_vendor_prices.map {|a| return a.price unless a.price == 0}
    prices.push(cost_price)
    return prices.min
  end

  def default_price
    self.prices.actual._public.default.minimum(:price).to_f
  end

  def actual_price(account_id = nil, quantity = nil)
    self.prices.actual.where('(appliable_type = ? AND appliable_id = ?) OR (appliable_type = ? AND appliable_id = ?) OR (appliable_type IS NULL AND appliable_id IS NULL)', (account_id ? 'Account' : nil), account_id, (account_id ? 'Group' : nil), (account_id ? Account.find(account_id).group_id : nil)).
      where('(_type = ? AND min_qty <= ? AND max_qty >= ?) OR (_type IN (?) AND min_qty IS NULL AND max_qty IS NULL)', (quantity ? 'Bulk' : nil), quantity, quantity, ['Default', 'Sale']).
      minimum(:price).to_f
  end

  def default_image_path
    unless images.first.nil?
      puts "----> #{images.first.path}"
      images.first.path
    end
  end
  
  def slugger
    self.slug = number.downcase.tr(" ", "-") unless self.number.nil?
  end
  
  def times_sold
    order_line_items.where(item_id: id).sum("COALESCE(quantity,0) - COALESCE(quantity_canceled,0)")
  end
  
  def times_ordered
    purchase_order_line_items.where(item_id: id).sum("COALESCE(quantity,0)")
  end
  
  def times_shipped
    inventory_transactions.where(:transaction_type => "LineItemShipment", item_id: id).sum("COALESCE(quantity,0)")
  end
  
  def times_received
    inventory_transactions.where(transaction_type: "PurchaseOrderLineItemReceipt", item_id: id).sum("COALESCE(quantity,0)")
  end
  
  def count_on_hand
    times_received.to_i - times_shipped.to_i
  end
  
  def negative_count_on_hand
    if count_on_hand < 0
      return true
    else
      return false
    end
  end
  
  def positive_count_on_hand
    if count_on_hand > 0
      return true
    else
      return false
    end
  end
  
  def times_purchased_by(account_id)
    Account.find(account_id).order_line_items.where(item_id: id).map(&:actual_quantity).sum
  end
  
  def self.times_ordered
    joins(:order_line_items)
    .group("items.id, item_id")
    .select("items.*")
    .select("SUM(COALESCE(order_line_items.quantity,0) - COALESCE(order_line_items.quantity_canceled,0)) AS times_ordered")
    .order("times_ordered DESC")
  end
  
  def self.negative_inventory
    ids = joins(:inventory_transactions).group(:id, :item_id).sort_by(&:negative_count_on_hand).map(&:id)
    where(id: ids)
  end
  
  def self.positive_inventory
    ids = joins(:inventory_transactions).group(:id, :item_id).sort_by(&:positive_count_on_hand).map(&:id)
    where(id: ids)
  end

  def one_default_price
    errors.add(:base, "Item needs to have at least one default price") if prices.select { |p| !p.marked_for_destruction? && p._type == 'Default' }.length == 0
  end
  
end