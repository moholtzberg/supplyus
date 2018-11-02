class AppliableItemPriceLimit < ActiveRecord::Base
  
  include ApplicationHelper
  
  belongs_to :appliable, polymorphic: true
  
  belongs_to :approver, class_name: "User", foreign_key: :approver_user_id
  validates_uniqueness_of :appliable_id, scope: :appliable_type
  APPLIABLE_TYPES = %w[Group Account User]
  
end