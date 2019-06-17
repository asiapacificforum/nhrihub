class ChangeOffencesToHumanRightsAttributes < ActiveRecord::Migration[4.2]
  def change
    connection.execute 'drop table if exists human_rights_attributes'
    rename_table :offences, :human_rights_attributes
    rename_column :indicators, :offence_id, :human_rights_attribute_id
  end
end
