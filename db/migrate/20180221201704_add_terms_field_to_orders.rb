class AddTermsFieldToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :terms, :string
  end
end