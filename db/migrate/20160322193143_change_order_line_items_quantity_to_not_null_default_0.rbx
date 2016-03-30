class ChangeOrderLineItemsQuantityToNotNullDefault0 < ActiveRecord::Migration
  def change
    change_column_default :order_line_items, :quantity, 0, :null => false
  end
end