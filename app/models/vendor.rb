class Vendor < Account
  
  has_many :item_vendor_prices
  
  # belongs_to :account
  # delegate :name, :number, :address_1, :address_2, :city, :state, :zip, :phone, :email, :fax, :active, :to => :account
  
  # def account_name
  #   account.try(:name)
  # end
  # 
  # def account_name=(name)
  #   self.account = Account.find_by(:name => name) if name.present?
  # end
  
end
