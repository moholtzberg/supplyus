class Contact < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :account
  has_one :user
  before_save :make_record_number
  
  validates :first_name, presence: true
  validates :email, presence: true
  
  scope :by_account, -> (account_id) { where(account_id: account_id) }
  
end