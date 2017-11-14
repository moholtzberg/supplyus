class Address < ActiveRecord::Base
    
  belongs_to :account

  validates :address_1, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true
  validates :name, :presence => true, uniqueness: { scope: :account_id }
  validates :account, :presence => true

  validate :one_main

  def self.lookup(term)
    includes(:account).where('lower(accounts.name) like (?) or lower(addresses.name) like (?) or lower(addresses.address_1) like (?) or lower(addresses.address_2) like (?)'\
      ' or lower(addresses.city) like (?) or lower(addresses.state) like (?) or lower(addresses.zip) like (?) or lower(addresses.phone) like (?) ', 
      "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:account)
  end
  
  def one_main
    errors.add(:main, "address could be only one per account") if account && account.addresses.where.not(id: id).where(main: true).any? && main
  end
  
  def account_name
    account.try(:name)
  end
  
  def account_name=(name)
    self.account = Account.find_by(:name => name) if name.present?
  end
  
end