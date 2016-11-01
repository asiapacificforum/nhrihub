class AddFieldsToComplaintsForImport < ActiveRecord::Migration[5.0]
  def change
    add_column :complaints, :desired_outcome, :text
    add_column :complaints, :complained_to_subject_agency, :boolean
  end
end
