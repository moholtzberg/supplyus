class ItemList < ActiveRecord::Base
  
  belongs_to :user
  has_many :items, through: :item_item_lists
  has_many :item_item_lists, dependent: :destroy
  accepts_nested_attributes_for :item_item_lists

  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates :user, presence: true

  def self.lookup(term)
    includes(:user).where("lower(users.first_name) like (?) or lower(users.last_name) like (?) or lower(users.email) like (?) or lower(item_lists.name) like (?)",
     "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:user)
  end

end
