class Address < ActiveRecord::Base
    
  belongs_to :account

  validates :address_1, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true

  validate :one_main

  def one_main
    errors.add(:main, "address could be only one per account") if account.addresses.where.not(id: id).where(main: true).any? && main
  end
  
end