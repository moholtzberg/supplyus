module DataMaintenance

  require 'sidekiq-scheduler'

  class ItemIndexWorker
    include Sidekiq::Worker
    include JobLogger

    def perform(item_id)
      add_log "Indexing Item #{item_id}"
      Item.find(item_id).index
    end
  end
  
end