class AddAppliableIdAndTypeToDiscountCodeRules < ActiveRecord::Migration
  
  def self.up
    add_column :discount_code_rules, :user_appliable_id, :integer
    add_column :discount_code_rules, :user_appliable_type, :string
  end
  
  def self.down
    remove_column :discount_code_rules, :user_appliable_id
    remove_column :discount_code_rules, :user_appliable_type
  end
  
end
