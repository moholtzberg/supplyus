class AddAmountToReturnAuthorization < ActiveRecord::Migration
  def change
    add_column :return_authorizations, :amount, :decimal
  end
end
