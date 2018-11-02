module DataMigrations

  require 'sidekiq-scheduler'

  class TestWorker
    include Sidekiq::Worker
    include JobLogger

    def perform
      add_log "Running the test worker #{Time.now}"
      puts "Running the test worker #{Time.now}"
    end
  end
  
end