class SkuGroupForm
  include ActiveModel::Model

  attr_accessor :name, :image_attachment, :image_alt, :id

  validates :name, presence: true
  validate :unique_name

  def initialize(attributes = {})
    super
    @sku_group = SkuGroup.find_or_initialize_by(id: @id)
    @image = @sku_group.image || @sku_group.build_image
    @name ||= @sku_group.name
    @image_attachment ||= @image.attachment
    @image_alt ||= @image.alt
  end

  def save
    return unless valid?
    ActiveRecord::Base.transaction do
      @sku_group.update_attributes(sku_group_attributes)
      if @image.persisted? || image_attributes.values.select(&:present?).any?
        @image.update_attributes(image_attributes)
      end
    end
  end

  private

  def sku_group_attributes
    { name: name }
  end

  def image_attributes
    { attachment: image_attachment, alt: image_alt }
  end

  def unique_name
    return if SkuGroup.where(name: name).where.not(id: id).empty?
    errors.add(:name, 'has already been taken')
  end
end
