class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  
  has_one :account
  has_many :user_accounts
  has_many :orders, :through => :account
  belongs_to :contact
  
  def has_account
    self.account.nil? ? false : true
  end
  
end
