class RemoveProjectConventionsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :project_conventions if table_exists? :project_conventions
  end
end
