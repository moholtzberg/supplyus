class AddDueDateToInvocies < ActiveRecord::Migration
  def change
    add_column :invoices, :due_date, :datetime
  end
end
