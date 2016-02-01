class Vendor < ActiveRecord::Base
  
  belongs_to :account
  delegate :name, :number, :address_1, :address_2, :city, :state, :zip, :phone, :email, :fax, :active, :to => :account
  
end
