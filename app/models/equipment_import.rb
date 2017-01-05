class EquipmentImport
  # switch to ActiveModel::Model in Rails 4
  include ActiveModel::Model
  attr_accessor :file
  attr_accessor :file_path
  attr_accessor :import_hisotry

  def put_file(file)
    @file = file
  end

  def file
    @file
  end

  def put_file_path(file_path)
    @file_path = file_path
  end

  def put_import_history(import_history)
    @import_history = import_history
  end

  def file_path
    @file_path
  end

  def import_history
    @import_history
  end

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    puts imported_products.inspect
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
    puts "loading imported products"
    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    puts spreadsheet.inspect
    spreadsheet.map do |row|
      puts row.inspect
      
      unless Equipment.find_by(:number => row["number"], :serial => row["serial"])
        item = Equipment.new
        item.customer = Customer.find_by(name: row["customer_name"])
        item.machine_model = MachineModel.find_or_create_by(make_id: Make.find_by(name: row["make"]).id,number: row["model_number"])
        item.attributes = row.to_hash.slice(*Equipment.attribute_names())
      else
        item = Equipment.find_by(:number => row["number"], :serial => row["serial"])
        id = item.id
        item.customer = Customer.find_by(name: row["customer_name"])
        item.machine_model = MachineModel.find_or_create_by(make_id: Make.find_by(name: row["make"]).id,number: row["model_number"])
        item.attributes = row.to_hash.slice(*Equipment.attribute_names())
        item.id = id
      end
      item
      # puts "--------------> #{item.inspect}"
      
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