class RenameCompletedAtToSubmittedAt < ActiveRecord::Migration
  def change
    rename_column :orders, :completed_at, :submitted_at
  end
end
