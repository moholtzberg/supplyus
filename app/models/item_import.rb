class ItemImport
  
  include ActiveModel::Model
  attr_accessor :file

  def put_file(file)
    @file = file
  end

  def file
    @file
  end

  def put_file_path(file_path)
    @file_path = file_path
  end

  def put_import_history
    @import_history = ImportHistory.last
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
    puts "---->>>>> #{imported_products.count}"
    i = 0
    import_history.update(nb_in_queue: imported_products.size, nb_failed: 0, nb_imported: 0, nb_last_id: nil, failed_lines: "", is_processing: 1)
    imported_products.each do |imp|
      i = i + 1

      if !imp.nil?
        item = imp
        # item.essendant_xml_import
        #Check if the object is valid
        if item == true
          import_history.update(nb_imported: import_history.nb_imported + 1, nb_last_id: imp.id)
          imp.save!
        else
          #Increment the number of faild raws
          import_history.update(nb_failed: import_history.nb_failed + 1)
          import_history.update(failed_lines: import_history.failed_lines.to_s + i.to_s + ", " )
        end
        true
      else
        import_history.update(nb_failed: import_history.nb_failed + 1)
        import_history.update(failed_lines: import_history.failed_lines + i.to_s + ", " )
      end
      import_history.update(nb_in_queue: import_history.nb_in_queue - 1)
    end
    #Update the import_history object when th processing is complete
    import_history.update(is_processing: 0)
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    import_history.update(nb_in_queue: spreadsheet.size)
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
        item
      end
    end
  
  end

end