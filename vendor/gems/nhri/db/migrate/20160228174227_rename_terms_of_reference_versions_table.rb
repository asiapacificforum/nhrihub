class RenameTermsOfReferenceVersionsTable < ActiveRecord::Migration[4.2]
  def change
    connection.execute 'drop table if exists advisory_council_documents'
    rename_table :terms_of_reference_versions, :advisory_council_documents
  end
end
