class CreateInvoicePaymentApplications < ActiveRecord::Migration
  def change
    create_table :invoice_payment_applications do |t|
      t.belongs_to :payment, index: true
      t.belongs_to :invoice, index: true
    end
  end
end
