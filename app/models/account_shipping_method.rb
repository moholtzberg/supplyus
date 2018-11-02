class AccountShippingMethod < ActiveRecord::Base
    
  belongs_to :account
  belongs_to :shipping_method

  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
end
