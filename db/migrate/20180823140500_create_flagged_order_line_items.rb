class CreateFlaggedOrderLineItems < ActiveRecord::Migration
  def change
    create_table :flagged_order_line_items do |t|
      t.integer  :order_line_item_id
      t.integer :appliable_item_price_limit_id
      t.integer :reviewer_user_id
      t.string :review_state
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end
