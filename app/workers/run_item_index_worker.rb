require 'sidekiq-scheduler'

class RunItemIndexWorker
  
  include Sidekiq::Worker
  
  def perform(start_id, end_id)
    puts "**** Starting to index #{(start_id..end_id).size} items ****"
    ih = ImportHistory.first
    start_time = Time.now
    puts "**** Start Time #{start_time}"
    ih.update_attributes(nb_in_queue: (start_id..end_id).size, is_processing: (start_id..end_id).size > 0, nb_imported: 0, nb_failed: 0)
    (start_id.to_i..end_id.to_i).each do |item_id|
      Item.find_by(id: item_id).index_async if Item.find_by(id: item_id)
    end
    end_time = Time.now
    puts "**** End Time #{end_time}"
    puts "**** Total Time Elapsed #{end_time - start_time}"
  end
  
end