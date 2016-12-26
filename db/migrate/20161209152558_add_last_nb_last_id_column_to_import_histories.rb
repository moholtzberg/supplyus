class AddLastNbLastIdColumnToImportHistories < ActiveRecord::Migration
  def change
    add_column :import_histories, :nb_last_id, :integer
  end
end
