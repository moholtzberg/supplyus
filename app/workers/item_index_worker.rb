require 'sidekiq-scheduler'

class ItemIndexWorker
  
  include Sidekiq::Worker
  
  def perform(start_id, end_id)
    Item.where(id: start_id..end_id).order(:id).map do |item_id|
      puts "Indexing Item #{item_id}"
      Item.find(item_id).index
    end
  end
  
end