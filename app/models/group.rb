class Group < ActiveRecord::Base
  
  has_many :accounts
  has_many :users
  
  def self.lookup(term)
    where("lower(name) like (?) or lower(description) like (?)", "%#{term.downcase}%", "%#{term.downcase}%")
  end
  
  def memebers
    # Rails.cache.fetch([self, "#{self.class.to_s.downcase}"]) {
    #   Rails.cache.delete("#{self.class.to_s.downcase}")
    #   sub_total.to_f + shipping_total.to_f
    # }
  end
  
end