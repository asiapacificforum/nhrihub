class RenameTermsOfReferenceVersionsTable < ActiveRecord::Migration
  def change
    rename_table :terms_of_reference_versions, :advisory_council_documents
  end
end
