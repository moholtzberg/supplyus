class ItemImport
  # switch to ActiveModel::Model in Rails 4
  include ActiveModel::Model
  # attr_accessor :file
  # attr_accessor :file_path
  # attr_accessor :import_hisotry

  def put_file(file)
    @file = file
  end

  def file
    @file
  end

  def put_file_path(file_path)
    @file_path = file_path
  end

  def put_import_hisotry(import_hisotry)
    @import_hisotry = import_hisotry
  end

  def file_path
    @file_path
  end

  def import_hisotry
    @import_hisotry
  end

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    puts "---->>>>> #{imported_products.inspect}"
    i = 0
    imported_products.each do |imp|
      i = i + 1
      if !imp.nil?
        #Check if the object is valid
        if imp.valid?
          import_hisotry.update(nb_imported: import_hisotry.nb_imported + 1)
          imp.save!
        else
          # imported_products.each_with_index do |product, index|
          #   product.errors.full_messages.each do |message|
          #     errors.add :base, "Row #{index+2}: #{message}"
          #   end
          # end
          # false
          #Increment the number of faild raws
          import_hisotry.update(nb_failed: import_hisotry.nb_failed + 1)
          import_hisotry.update(failed_lines: import_hisotry.failed_lines + i.to_s + ", " )
        end
        true
      else
        import_hisotry.update(nb_failed: import_hisotry.nb_failed + 1)
        import_hisotry.update(failed_lines: import_hisotry.failed_lines + i.to_s + ", " )
      end
      import_hisotry.update(nb_in_queue: import_hisotry.nb_in_queue - 1)
    end
    #Update the import_history object when th processing is complete
    import_hisotry.update(is_processing: 0)
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products

    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    # header = spreadsheet[0]
    import_hisotry.update(nb_in_queue: spreadsheet.size)
    spreadsheet.map do |row|
      if row["price"].to_f > 0 and row["cost_price"].to_f > 0
        unless Item.find_by(:number => row["number"])
          item = Item.new
          item.attributes = row.to_hash.slice(*Item.attribute_names())
        else
          item = Item.find_by(:number => row["number"])
          id = item.id
          item.attributes = row.to_hash.slice(*Item.attribute_names())
          item.id = id
        end
        # puts "----> #{item.inspect}"
        item
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