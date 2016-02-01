class CreatePaymentPlanTemplates < ActiveRecord::Migration
  def change
    create_table :payment_plan_templates do |t|
      t.text :name
      t.float :amount
    end
  end
end
