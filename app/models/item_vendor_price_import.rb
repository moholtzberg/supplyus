class ItemVendorPriceImport
  # switch to ActiveModel::Model in Rails 4
  include ActiveModel::Model

  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    imported_products.each {|im| puts "--MM #{im.inspect}"}
    if imported_products.map(&:valid?).all?
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = CSV.read(file.path, :headers => true, :encoding => 'ISO-8859-1')
    spreadsheet.map do |row|
      
      item = Item.find_by(:number => row["number"])
      
      if item.nil?
        item = Item.create(:number => row["number"], :list_price => row["list_price"], :cost_price => row["cost_price"])
      end
      
      product = ItemVendorPrice.where(item_id: item.id, vendor_id: row["vendor_id"]).first
      
      if product.nil?
        product = ItemVendorPrice.new
      end
      
      id = product.id
      attributes = row.to_hash.slice(*ItemVendorPrice.attribute_names())
      product.id = id unless id.nil?
      product.vendor_id = attributes["vendor_id"]
      product.item_id = item.id
      product.price = attributes["cost_price"]
      product.vendor_item_number = attributes["number"]
      product
      
      # product = ItemVendorPrice.new(:vendor_id => row["vendor_id"], :price => row["price"])
      # errors.add(:item, "#{row["item_number"]} cannot be not be found")
      # product
    end
  end


  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Spreadsheet.open(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end