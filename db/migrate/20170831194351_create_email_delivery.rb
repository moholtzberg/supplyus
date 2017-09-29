class CreateEmailDelivery < ActiveRecord::Migration
  def change
    create_table :email_deliveries do |t|
      t.string :addressable_type
      t.integer :addressable_id
      t.string :to_email
      t.text :body
      t.string :eventable_type
      t.integer :eventable_id
      t.datetime :failed_at
      t.datetime :delivered_at
      t.datetime :opened_at
    end
  end
end
