require 'sidekiq-scheduler'

class TestWorker
  
  include Sidekiq::Worker
  
  def perform()
    puts "Running a test worker"
  end
  
end