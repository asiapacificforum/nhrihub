class ChangeOffencesToHumanRightsAttributes < ActiveRecord::Migration
  def change
    rename_table :offences, :human_rights_attributes
    rename_column :indicators, :offence_id, :human_rights_attribute_id
  end
end
