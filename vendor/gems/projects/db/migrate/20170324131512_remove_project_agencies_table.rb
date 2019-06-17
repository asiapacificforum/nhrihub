class RemoveProjectAgenciesTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :project_agencies if table_exists? :project_agencies
  end
end
