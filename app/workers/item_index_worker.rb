require 'sidekiq-scheduler'

class ItemIndexWorker
  
  include Sidekiq::Worker
  
  def perform(item_id)
    puts "Indexing Item #{item_id}"
    Item.find(item_id).index
    ih = ImportHistory.first
    ih.nb_last_id = item_id
    ih.nb_in_queue -= 1
    ih.nb_imported += 1
    ih.is_processing = (ih.nb_in_queue > 0)
    ih.save
  end
  
end