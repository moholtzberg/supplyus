class PriceImport
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
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each_row do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if Item.find_by(:number => row["item_number"])
        item = Item.find_by(:number => row["item_number"])
        product = Price.new
        attributes = row.to_hash.slice(*Price.attribute_names())
        product.id = attributes["id"]
        product.min_qty = attributes["min_qty"]
        product.max_qty = attributes["max_qty"]
        product._type = attributes["_type"]
        product.start_date = attributes["start_date"]
        product.end_date = attributes["end_date"]
        product.combinable = attributes["combinable"]
        product.appliable_id = attributes["appliable_id"]
        product.appliable_type = attributes["appliable_type"]
        product.price = attributes["price"]
        product
      else
        product = Price.new(:price => row["price"], :min_qty => row["min_qty"], 
          :max_qty => row["max_qty"], :_type => row["_type"], :start_date => row[:start_date], :end_date => row[:end_date], 
          :combinable => row[:combinable], :appliable_id => row[:appliable_id], :appliable_type => row[:appliable_type])
        errors.add(:item, "#{row["item_number"]} cannot be not be found")
        product
      end
      
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