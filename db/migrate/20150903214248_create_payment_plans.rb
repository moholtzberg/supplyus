class CreatePaymentPlans < ActiveRecord::Migration
  def change
    create_table :payment_plans do |t|
      t.text :name
      t.belongs_to :account
      t.belongs_to :payment_plan_template
      t.date :billing_start
      t.date :billing_end
      t.date :last_billing_date
      t.float :amount
    end
  end
end
