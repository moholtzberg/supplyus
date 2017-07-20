class CreateSubscription < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :address_id
      t.integer :item_id
      t.integer :quantity
      t.integer :frequency
    end
  end
end
