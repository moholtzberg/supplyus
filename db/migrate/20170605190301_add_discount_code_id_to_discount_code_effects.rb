class AddDiscountCodeIdToDiscountCodeEffects < ActiveRecord::Migration
  def change
    add_column :discount_code_effects, :discount_code_id, :integer
  end
end
