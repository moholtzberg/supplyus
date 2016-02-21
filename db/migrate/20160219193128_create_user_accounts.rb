class CreateUserAccounts < ActiveRecord::Migration
  def change
    create_table :user_accounts do |t|
      t.belongs_to :user
      t.belongs_to :account
    end
  end
end
