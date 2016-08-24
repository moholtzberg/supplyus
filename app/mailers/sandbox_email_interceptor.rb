class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['admin@247officesupply.com']
    message.bcc = nil
    message.subject = "TEST EMAIL --> #{message.subject}"
  end
end