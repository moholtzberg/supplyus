class SkuGroup < ActiveRecord::Base
  has_many :items
  has_one :image, as: :attachable
  validates :name, presence: true, uniqueness: true

  def self.lookup(term)
    where('lower(name) like (?)', "%#{term.to_s.downcase}%")
  end

  def image_url
    image.attachment.url if image
  end

  def to_select2
    { id: id, text: name }
  end
end
