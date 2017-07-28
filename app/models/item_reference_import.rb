class ItemReferenceImport
  
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

  def put_import_history(file_path)
    @import_history = file_path
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
    # imported_products.each do |imp|
    #   if imp
    #     imp
    #   end
    # end
    imported_products.each_with_index do |imp, index|

      import_history.update(nb_in_queue: (import_history.nb_in_queue - (index + 1)))

      if imp.nil?
        import_history.update(nb_failed: (import_history.nb_failed + 1))
      else
        import_history.update(nb_imported: (import_history.nb_imported + 1))
      end
    end

    import_history.update(is_processing: false)
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products
    spreadsheet = CSV.read(file_path || file.path, :headers => true, :encoding => 'ISO-8859-1')
    import_history.update(nb_in_queue: 150, is_processing: true, nb_imported: 0, nb_failed: 0, failed_lines: nil)
    #spreadsheet.first(50).each_with_index do |row, index|
      #puts "#{index} -> #{row}"
      batch = Sidekiq::Batch.new
      batch.jobs do
        
        spreadsheet.first(150).each_with_index {|row, index| ImportItemReferenceRowWorker.perform_async(row.to_hash, index, import_history.id)}
      end
      # original_item = Item.find_by(number: row["reseller_item_number"])
#       replacement_item = Item.find_by(number: row["essendant_item_number"])
#
#       if original_item and replacement_item
#         puts "----> #{original_item.number} + #{replacement_item.number}"
#         unless ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
#           ref = ItemReference.new(original_item_id: original_item.id, replacement_item_id: replacement_item.id, original_uom: row["essendant_uom"], repacement_uom: row["reseller_uom"], original_uom_qty: row["essendant_uom_qty"], replacement_uom_qty: row["reseller_uom_qty"], comments: row["comments"], match_type: row["match_type"], xref_type: row["xref_type"])
#         else
#           ref =  ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
#           ref.original_item_id = original_item.id
#           ref.replacement_item_id = replacement_item.id
#           ref.original_uom = row["essendant_uom"]
#           ref.repacement_uom = row["reseller_uom"]
#           ref.original_uom_qty = row["essendant_uom_qty"]
#           ref.replacement_uom_qty = row["reseller_uom_qty"]
#           ref.comments = row["comments"]
#           ref.match_type = row["match_type"]
#           ref.xref_type = row["xref_type"]
#         end
#       end
    # end
  end

end