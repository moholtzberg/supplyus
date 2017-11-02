require 'sidekiq'
require 'sidekiq/scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Scheduler.dynamic = true
    Sidekiq.schedule = Schedule.all.map do |schedule|
      [
        schedule.name,
        {
          cron: schedule.cron,
          class: schedule.worker,
          args: schedule.arguments,
          description: schedule.description,
          enabled: schedule.enabled
        }
      ]
    end.to_h
    Sidekiq::Scheduler.reload_schedule!
  end
end
