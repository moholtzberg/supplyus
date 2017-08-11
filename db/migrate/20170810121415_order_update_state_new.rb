class OrderUpdateStateNew < ActiveRecord::Migration
  def change
    Order.where(state: :new).update_all(state: :incomplete)
  end
end
