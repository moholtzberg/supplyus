class SetPositionForImage < ActiveRecord::Migration
  def self.up
    Item.all.each do |item|
      item.images.each_with_index do |img, index|
        img.update_column(:position, index + 1)
      end
    end
  end

  def self.down
  end
end
