class Schedule < ActiveRecord::Base
  validates_presence_of :cron, :worker
  before_save :set_name, unless: proc { |s| s.name }
  after_save :update_schedule
  after_destroy :remove_schedule

  def self.lookup(term)
    where('lower(worker) like (?) or lower(name) like (?)'\
          'or lower(arguments) like (?) or lower(arguments) like (?)',
          "%#{term.downcase}%", "%#{term.downcase}%",
          "%#{term.downcase}%", "%#{term.downcase}%")
  end

  def set_name
    self.name = worker
  end

  def update_schedule
    remove_schedule if name_changed?
    Sidekiq.set_schedule(
      name,
      class: worker,
      enabled: enabled,
      cron: cron,
      args: arguments,
      description: description
    )
  end

  def remove_schedule
    Sidekiq.remove_schedule(name_was)
  end
end
