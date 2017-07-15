class AddLast4ToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :last_4, :string
  end
end
