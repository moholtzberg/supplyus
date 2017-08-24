class Asset < ActiveRecord::Base

  TYPES = ['Image', 'Document']

  has_attached_file :attachment
  validates :attachment, attachment_presence: true
  validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf"]

  belongs_to :item
  acts_as_list
  before_save :set_dimensions
  before_save :set_type, if: :attachment_changed?
  serialize :dimensions

  def self.lookup(term)
    includes(:item).where('lower(assets.attachment_file_name) like (?) or lower(items.number) like (?)', "%#{term.downcase}%", "%#{term.downcase}%").references(:item)
  end

  def scope_condition
    ['item_id = ? AND item_id IS NOT NULL', item_id]
  end

  def item_number
    Item.find(item_id).try(:number) if item_id
  end

  def item_number=(name)
    self.item_id = Item.find_by(:number => name)&.id if name.present?
  end

  def to_fileinput_hash
    {filetype: attachment_content_type, caption: attachment_file_name.gsub(/(.*)\.\w*$/, '\1'), key: id, extra: {position: position, id: id}}
  end

  def set_type
    self.image? ? self.type = 'Image' : self.type = 'Document'
  end

  def image?
    attachment_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

  def attachment_changed?
    attachment.dirty?
  end

  def set_dimensions
    return unless image?
    tempfile = attachment.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.attachment_width = geometry.width.to_i
      self.attachment_height = geometry.height.to_i
    end
  end
end