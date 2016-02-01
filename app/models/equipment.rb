class Equipment < ActiveRecord::Base
  include ApplicationHelper
  
  before_save :make_record_number
  
  belongs_to :account
  has_one :contact
  has_many :meters
  
end