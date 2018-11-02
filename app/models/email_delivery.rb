class EmailDelivery < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true
  belongs_to :eventable, polymorphic: true

  validates :to_email, presence: true
end
