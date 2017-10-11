class ImportItemReferenceRowWorker
  include Sidekiq::Worker
  include JobLogger
  
  def perform(row, index, import_history_id)
    import_history = ImportHistory.find(import_history_id)
    add_log "#{index} -> #{row["reseller_item_number"]}"
    original_item = Item.find_by(number: row["reseller_item_number"])
    replacement_item = Item.find_by(number: row["essendant_item_number"])
    add_log "----------------------------------------------------------------> #{index} -> #{row['reseller_item_number']} -> #{import_history.nb_in_queue}"
    # import_history.update(nb_in_queue: (import_history.nb_in_queue - 1))
    unless original_item and replacement_item
      # import_history.update(nb_failed: (import_history.nb_failed + 1))
    else
      add_log "----> #{original_item.number} + #{replacement_item.number}"
      unless ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
        ref = ItemReference.new(original_item_id: original_item.id, replacement_item_id: replacement_item.id, original_uom: row["essendant_uom"], repacement_uom: row["reseller_uom"], original_uom_qty: row["essendant_uom_qty"], replacement_uom_qty: row["reseller_uom_qty"], comments: row["comments"], match_type: row["match_type"], xref_type: row["xref_type"])
      else
        ref = ItemReference.find_by(original_item_id: original_item.id, replacement_item_id: replacement_item.id)
        ref.original_item_id = original_item.id
        ref.replacement_item_id = replacement_item.id
        ref.original_uom = row["essendant_uom"]
        ref.repacement_uom = row["reseller_uom"]
        ref.original_uom_qty = row["essendant_uom_qty"]
        ref.replacement_uom_qty = row["reseller_uom_qty"]
        ref.comments = row["comments"]
        ref.match_type = row["match_type"]
        ref.xref_type = row["xref_type"]
      end
      ref.save
      # import_history.update(nb_imported: (import_history.nb_imported + 1))
    end
    
  end
  
end