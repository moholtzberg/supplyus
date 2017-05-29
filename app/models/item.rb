class Item < ActiveRecord::Base
  
  include ApplicationHelper
  
  scope :active, -> { where(:active => true)}
  scope :inactive, -> { where(:active => false)}
  
  has_many :account_item_prices, :dependent => :destroy, :inverse_of => :item
  has_many :group_item_prices, :dependent => :destroy, :inverse_of => :item
  has_many :item_vendor_prices
  has_many :images  
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
  belongs_to :category
  belongs_to :brand
  belongs_to :model
  has_one :inventory, :class_name => "Inventory"
  attr_reader :category_tokens
  
  validates_uniqueness_of :number
  # validates_uniqueness_of :slug
  
  before_validation :slugger
  
  searchable do
    text :number, :stored => true, :boost => 32
    text :name, :stored => true, :boost => 16
    text :description, :stored => true, :boost => 8
    
    text :brand, :boost => 4 do
      brand.name if brand
    end
    
    text :item_categories, :boost => 4 do
      item_categories.map { |item_category| item_category.category.name }
    end

    text :item_properties do
      item_properties.map { |item_property| item_property.value }
    end
    
    float :price, :trie => true
    
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
  
  def actual_price(account_id={})
    unless account_id.blank?
      unless get_lowest_price(account_id).blank?
        return [get_lowest_price(account_id), get_lowest_public_price].min
      else
        return get_lowest_public_price
      end
      return get_lowest_public_price
    end
  end
  
  def get_lowest_public_price
    prices_array = []
    if sale_price.to_f > 0
      prices_array << sale_price.to_f
    end
    prices_array << price
    price = prices_array.min
    return price == 0 ? false : price
  end
  
  def get_lowest_price(account_id)
    acct_price = get_account_price(account_id).to_f
    group_price = get_group_price(account_id).to_f
    prices_array = []
    if acct_price > 0
      prices_array << acct_price
    end
    if group_price > 0
      prices_array << group_price
    end
    puts "PRICES ARRAY #{prices_array.inspect}"
    price = prices_array.min
    return price == 0 ? false : price
  end
  
  def get_account_price(account_id)
    if has_account_price(account_id)
      self.account_item_prices.by_account(account_id).last.price
    end
  end
  
  def get_group_price(account_id)
    group_id = Account.find(account_id).group_id
    if has_group_price(group_id)
      self.group_item_prices.by_group(group_id).last.price
    end
  end
  
  def has_account_price(account_id)
    return !self.account_item_prices.by_account(account_id).blank? 
  end
  
  def has_group_price(group_id)
    return !self.group_item_prices.by_group(group_id).blank? 
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
  
  def essendant_xml_import
    update_columns(:updated_at => Time.now)
    start = Time.now
    
    puts "START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{id}"
    
    current_item_id = id
    
    path = "Users/Moshe/Documents/ecdb/xml/individual_items/ecdb.individual_items"
    
    begin
      noko = File.open("/#{path}/#{number}.xml") { |f| Nokogiri::XML(f) }
    rescue
      
      unless self.number.ends_with? "COMP"
        update_attributes(:active => false)
      end
      
      puts "No such file #{number}.xml"
      return false
    else
      result = current_item_id.even?
      # self.item_properties.delete_all

      ItemProperty.delete_all(:item_id => self.id)
      puts "deleted item properties"
      unless noko.xpath("//us:GlobalItem//us:GTINItem").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_item", value: noko.xpath("//us:GlobalItem//us:GTINItem").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINCarton").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_carton", value: noko.xpath("//us:GlobalItem//us:GTINCarton").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINBox").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_box", value: noko.xpath("//us:GlobalItem//us:GTINBox").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINPallet").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_pallet", value: noko.xpath("//us:GlobalItem//us:GTINPallet").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:UPCRetail").nil?
        ItemProperty.create(item_id: current_item_id, key: "upc_retail", value: noko.xpath("//us:GlobalItem//us:UPCRetail").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:UPCCarton").nil?
        ItemProperty.create(item_id: current_item_id, key: "upc_carton", value: noko.xpath("//us:GlobalItem//us:UPCCarton").text, active: true, :type => "Property")
      end

      unless noko.css("[status=Summary_Selling_Statement]").nil?
        ItemProperty.create(item_id: current_item_id, key: "summary_selling_statement", value: noko.css("[status=Summary_Selling_Statement]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_1]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_1", value: noko.css("[status=Selling_Point_1]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_2]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_2", value: noko.css("[status=Selling_Point_2]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_3]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_3", value: noko.css("[status=Selling_Point_3]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_4]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_4", value: noko.css("[status=Selling_Point_4]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_5]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_5", value: noko.css("[status=Selling_Point_5]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_6]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_6", value: noko.css("[status=Selling_Point_6]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_7]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_7", value: noko.css("[status=Selling_Point_7]").text, active: true, :type => "Feature")
      end

      noko.xpath("//oa:Specification//oa:Property//oa:NameValue").each_with_index do |k,v, index|
        ItemProperty.create(:item_id => current_item_id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
      end
      puts "matchbook starting"
      noko.xpath("//us:Matchbook").each_with_index.map do |k, index|
        ItemProperty.create(:item_id => self.id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
        rel_make    = noko.xpath("//us:Matchbook")[index].element_children[0].element_children[0].text
        rel_family  = noko.xpath("//us:Matchbook")[index].element_children[2].text
        rel_model   = noko.xpath("//us:Matchbook")[index].element_children[3].text

        cat = Category.find_by(:slug => "inks-toners")

        make_slug = rel_make.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        make = Category.find_or_create_by(:name => rel_make, :parent_id => cat.id, :slug => make_slug)

        family_slug = rel_family.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        family = Category.find_or_create_by(:name => rel_family, :parent_id => make.id, :slug => family_slug)

        model_slug = rel_model.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        imodel = Category.find_or_create_by(:name => rel_model, :parent_id => family.id, :slug => model_slug)

        ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => imodel.id)
      end
      
      # (0..(noko.xpath("//us:Matchbook").count)-1).each {|i| puts noko.xpath("//us:Matchbook//us:Device")[i] }
      
      brand = Brand.find_by(:prefix => noko.css("[agencyRole=Prefix_Number]").text.gsub(/\s+/, ""))
      brand = brand.id unless brand.nil?

      noko.css("[listName=HierarchyLevel1]").map do |cat1|
        cat1_slug = cat1.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        Category.find_or_create_by(:name => cat1.text, slug: cat1_slug)
      end

      noko.css("[listName=HierarchyLevel2]").each_with_index.map do |cat2, index|
        cat1 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel1]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
        cat2_slug = cat2.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        Category.find_or_create_by(name: cat2.text, slug: cat2_slug, parent_id: cat1.id)
      end

      noko.css("[listName=HierarchyLevel3]").each_with_index.map do |cat3, index|
        cat2 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel2]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
        cat3_slug = cat3.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        cat3 = Category.find_or_create_by(name: cat3.text, slug: cat3_slug, parent_id: cat2.id)
        ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => cat3.id)
      end
      
      height = noko.xpath("//us:Packaging//us:Dimensions//oa:HeightMeasure").text
      width = noko.xpath("//us:Packaging//us:Dimensions//oa:WidthMeasure").text
      length = noko.xpath("//us:Packaging//us:Dimensions//oa:LengthMeasure").text
      wieght = noko.xpath("//us:Packaging//us:Dimensions//us:WeightMeasure").text
      
      # list_price = noko.xpath("//us:ItemList//us:ListAmount").text
      #
      active = noko.xpath("//oa:ItemStatus//oa:Code").text
      active = (active == "Y" )? true : false

      name = noko.css("[type=Long_Item_Description]").text
      description = noko.css("[type=Item_Consolidated_Copy]").text
     
      update_attributes(:brand_id => brand, :slug => self.number.downcase, :height => height, :width => width, :length => length, :weight => weight, :name => name, :description => description, :active => active)
      
      Image.delete_all(:item_id => self.id)

      image_array = []
      image_array.push noko.xpath("//oa:DrawingAttachment//oa:FileName").text
      noko.xpath("//oa:Attachment//oa:FileName").text.split(";").map {|a| image_array.push a}

      if image_array.empty?
        image_array.push noko.xpath("//us:SkuGroupImage").text
      end

      image_array.each_with_index.map do |single_image, pos|

        image = single_image.tr(" ", "")

        if image
          item_images = self.images
          unless Image.find_by(item_id: id, attachment_file_name: image)
            img = Image.create(:item_id => id, :attachment_file_name => image, :position => pos)
            img.upload_from_oppictures_to_s3 unless image == "NOA.JPG"
          else
            img = Image.find_by(id: self.images.first.id).update_attributes(:item_id => current_item_id, :attachment_file_name => image, :position => pos) unless image == "NOA.JPG"
            img.upload_from_oppictures_to_s3 unless image == "NOA.JPG"
          end
        end

      end

      noa_image = Image.find_by(:item_id => current_item_id, :attachment_file_name => "NOA.JPG")

      if noa_image.present?
        noa_image.delete
      end
      
    end
    puts "FINISH TIME ELAPSED -> #{Time.now - start} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #{id}"
    result
  end
  
end