class AccountItemPriceImport
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
      # product = AccountItemPrice.find_by_id(row["id"])
      if Item.find_by(:number => row["item_number"])
        item = Item.find_by(:number => row["item_number"])
        product = AccountItemPrice.by_item(item.id).by_account(row["account_id"]).first
        if product.nil?
          product = AccountItemPrice.new
        end
        id = product.id
        attributes = row.to_hash.slice(*AccountItemPrice.attribute_names())
        product.id = id unless id.nil?
        product.account_id = attributes["account_id"]
        product.item_id = item.id
        product.price = attributes["price"]
        product
      else
        product = AccountItemPrice.new(:account_id => row["account_id"], :price => row["price"])
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