require 'sidekiq-scheduler'

class TestWorker
  include Sidekiq::Worker
  include JobLogger

  def perform
    add_log 'Running a test worker'
  end
end
