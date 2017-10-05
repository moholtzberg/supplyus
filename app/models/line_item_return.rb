class LineItemReturn < ActiveRecord::Base
  belongs_to :order_line_item
  belongs_to :return_authorization
  belongs_to :bin
  has_many :inventory_transactions, as: :inv_transaction, dependent: :destroy

  def create_inventory_transactions
    i = InventoryTransaction.find_or_create_by(
      inv_transaction_id: id,
      inv_transaction_type: 'LineItemReturn'
    )
    i.update_attributes(
      quantity: quantity,
      inventory_id: bin.inventories
                       .find_or_create_by(item_id: order_line_item.item_id).id
    )
  end

  def destroy_inventory_transactions
    inventory_transactions.each(&:destroy)
  end

  def recalculate_line_item
    order_line_item.update_quantities
  end

  def ancestor
    order_line_item.order
  end

  def ancestor_title
    ancestor.number
  end

  def calculate_refund
    base = order_line_item.price * quantity
    discount = order_line_item.applied_discount.to_f * quantity /
               order_line_item.actual_quantity
    base - discount
  end
end
