class AddViolationSeverityAssociationToMediaAppearances < ActiveRecord::Migration[4.2]
  def change
    remove_column :media_appearances, :violation_severity
    add_column :media_appearances, :violation_severity_id, :integer
  end
end
