class CreateLineItemReturn < ActiveRecord::Migration
  def change
    create_table :line_item_returns do |t|
      t.integer :order_line_item_id
      t.integer :return_authorization_id
      t.integer :quantity
      t.integer :bin_id
    end
  end
end
