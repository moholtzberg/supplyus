module EmailDeliveryServices
  class VerifyWebhook
    def call(token, timestamp, signature)
      api_key = SECRET['MAILGUN_API_KEY']
      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
    end
  end
end
