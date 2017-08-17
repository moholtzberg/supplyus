class Address < ActiveRecord::Base
    
  belongs_to :account

  validates :address_1, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true
  validates :name, :presence => true, uniqueness: { scope: :account_id }

  validate :one_main

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