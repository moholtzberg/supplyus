class UserItemList < ActiveRecord::Base
  belongs_to :item_list
  belongs_to :user
  validates :item_list_id, presence: true, uniqueness: { scope: :user, message: "This list already exists this this user" }
  validates :user_id, presence: true
  
  def user_name
    user.try(:email)
  end
  
  def user_name=(email)
    self.user = User.find_by(:email => email) if email.present?
  end
  
  def self.lookup(term)
    includes(:make).where("lower(models.number) like (?) or lower(makes.name) like (?)", "%#{term.downcase}%", "%#{term.downcase}%").references(:make)
  end
  
end
