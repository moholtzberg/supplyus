class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.bcc = nil
    message.subject = "TEST EMAIL --> #{message.subject}"
  end
end