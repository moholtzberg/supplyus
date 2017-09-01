class EmailDelivery < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true
  belongs_to :eventable, polymorphic: true

  validates :to_email, presence: true

  def self.verify_webhook(token, timestamp, signature)
    api_key = SECRET['MAILGUN_API_KEY']
    digest = OpenSSL::Digest::SHA256.new
    data = [timestamp, token].join
    signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)
  end
end