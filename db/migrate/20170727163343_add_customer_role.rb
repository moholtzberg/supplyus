class AddCustomerRole < ActiveRecord::Migration
  def change
    User.where.not(id: User.joins(:users_roles)).each { |user| user.add_role :customer }
  end
end
