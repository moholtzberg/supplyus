class Group < ActiveRecord::Base
  
  has_many :accounts
  has_many :orders, :through => :accounts
  has_many :users
  has_many :prices, as: :appliable
  
  def self.lookup(term)
    where("lower(name) like (?) or lower(description) like (?)", "%#{term.downcase}%", "%#{term.downcase}%")
  end
  
  def members
    Rails.cache.fetch([self, "#{self.class.to_s.downcase}"]) {
      Rails.cache.delete("#{self.class.to_s.downcase}")
      Account.where(group_id: self.id)
    }
  end
  
end