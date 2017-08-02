class Bin < ActiveRecord::Base

  TYPES = ['good', 'bad']
  
  has_many :inventories
  has_many :purchase_order_line_item_receipts
  belongs_to :warehouse
  
  validates :name, presence: true, uniqueness: { scope: :warehouse_id }
  validates :_type, presence: true, inclusion: { in: TYPES }
  validates :warehouse, presence: true

  def self.lookup(word)
    where("lower(name) like ?", "%#{word.downcase}%")
  end

end