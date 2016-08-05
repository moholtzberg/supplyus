class CreatePurchaseOrderReceipts < ActiveRecord::Migration
  def change
    create_table :purchase_order_receipts do |t|
      t.belongs_to :purchase_order
      t.string :number
      t.datetime :date      
    end
  end
end
