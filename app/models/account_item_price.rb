class AccountItemPrice < ActiveRecord::Base
  
  belongs_to :account
  belongs_to :item
  
  validates :account_id, :presence => true
  validates :item_id, :presence => true
  validates :price, :presence => true, :numericality => true
  
  scope :by_account, -> (account_id) { where(account_id: account_id)}
  scope :by_item, -> (item_id) { where(item_id: item_id)}
  
end
