class AddDiscountCodeIdToDiscountCodeRules < ActiveRecord::Migration
  def change
    add_column :discount_code_rules, :discount_code_id, :integer
  end
end
