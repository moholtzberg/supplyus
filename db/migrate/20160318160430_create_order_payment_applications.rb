class CreateOrderPaymentApplications < ActiveRecord::Migration
  def change
    create_table :order_payment_applications do |t|
      t.belongs_to :payment, index: true
      t.belongs_to :order, index: true
      t.timestamps
    end
  end
end
