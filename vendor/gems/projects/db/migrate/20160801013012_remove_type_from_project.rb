class RemoveTypeFromProject < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :type if column_exists? :projects, :type
  end
end
