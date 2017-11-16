class AccountItemPrice < ActiveRecord::Base
  
  belongs_to :account
  belongs_to :item
  
  validates :account_id, :presence => true
  validates :item_id, :presence => true
  validates :price, :presence => true, :numericality => true
  
  scope :by_account, -> (account_id) { where(account_id: account_id)}
  scope :by_item, -> (item_id) { where(item_id: item_id)}
  
  scope :order_by_item, -> () { order(:item_id => :asc)}
  
  def item_number
    item.try(:number)
  end
  
  def item_number=(number)
    self.item = Item.find_by(:number => number) if number.present?
  end
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.acaount = Account.find_by(:name => name) if name.present?
  end
  
  def copy_from=(account)
    Account.find_by(:name => account) if account.present?
  end
  
  def copy_from
  end
  
end
