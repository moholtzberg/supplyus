class AddNameToDiscountCodeEffects < ActiveRecord::Migration
  def change
    add_column :discount_code_effects, :name, :string
  end
end
