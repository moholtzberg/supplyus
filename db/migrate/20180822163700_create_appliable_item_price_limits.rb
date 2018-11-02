class CreateAppliableItemPriceLimits < ActiveRecord::Migration
  def change
    create_table :appliable_item_price_limits do |t|
      t.string  :appliable_type
      t.integer :appliable_id
      t.decimal :amount
      t.integer :approver_user_id
      t.boolean :hold_order, default: true
      t.timestamps
    end
  end
end
