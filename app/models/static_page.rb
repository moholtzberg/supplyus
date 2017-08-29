class StaticPage < ActiveRecord::Base

  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true

  def self.lookup(word)
    where("lower(title) like ? or lower(content) like ?", "%#{word.downcase}%", "%#{word.downcase}%")
  end

end