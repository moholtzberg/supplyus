class AddFiledsToImportHistory < ActiveRecord::Migration
  def change
  	add_column :import_histories, :is_processing, :integer, :default => 0
  	add_column :import_histories, :failed_lines, :text, :default => ""
  end
end
