class Transfer < ActiveRecord::Base

  attr_accessor :bin_name

  belongs_to :from, class_name: 'Inventory'
  belongs_to :to, class_name: 'Bin'
  has_many :inventory_transactions, as: :inv_transaction, dependent: :destroy

  validates_presence_of :from, :to, :quantity
  validate :different_bin

  after_commit :create_inventory_transactions, on: :create
  
  def create_inventory_transactions
    InventoryTransaction.create(:inv_transaction_id => id, :inv_transaction_type => "Transfer", :inventory_id => from.id, :quantity => -quantity)
    InventoryTransaction.create(:inv_transaction_id => id, :inv_transaction_type => "Transfer", :inventory_id => to.inventories.find_or_create_by(item_id: from.item_id).id, :quantity => quantity)
  end

  def different_bin
    from.bin != to
  end
  
end