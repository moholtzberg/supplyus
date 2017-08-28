class Asset < ActiveRecord::Base

  TYPES = ['Image', 'Document']
  ATTACHABLE_TYPES = ['Item', 'Category']

  has_attached_file :attachment
  validates :attachment, attachment_presence: true
  validates_attachment_content_type :attachment, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf"]
  validates :attachable_type, presence: true, if: Proc.new { |asset| asset.attachable_id }
  validates :attachable_id, presence: true, if: Proc.new { |asset| asset.attachable_type }

  belongs_to :attachable, polymorphic: true
  belongs_to :item, -> { where(assets: {attachable_type: 'Item'}) }, foreign_key: 'attachable_id'
  belongs_to :category, -> { where(assets: {attachable_type: 'Category'}) }, foreign_key: 'attachable_id'
  acts_as_list scope: [:attachable_id, :attachable_type]

  before_validation :set_blank_to_nil
  before_save :set_dimensions
  before_save :set_type, if: :attachment_changed?
  after_save :remove_position, if: Proc.new { |asset| asset.attachable.nil? }
  serialize :dimensions

  def self.lookup(term)
    includes(:item, :category).where('lower(assets.attachment_file_name) like (?) or lower(items.number) like (?) or lower(categories.name) like (?)',
     "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%").references(:item, :category)
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

  def attachable_name
    if attachable_type == 'Item'
      attachable.number
    elsif attachable_type == 'Category'
      attachable.name
    end
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

  def remove_position
    update_column(:position, nil)
  end

  def set_blank_to_nil
    self.attachable_type = nil if self.attachable_type.blank?
  end
end