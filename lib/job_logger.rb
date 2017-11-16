module JobLogger
  def job_logger
    @job_logger ||= Job.create(job_name: self.class, notes: '')
  end

  def add_log(note)
    job_logger.update_attribute(:notes, (job_logger.notes += note.concat("\n")))
  end

  def logger_name(name)
    job_logger.update_attribute(job_name: name)
  end
end
