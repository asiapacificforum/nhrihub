class AddTypeFieldToAdvisoryCouncilDocuments < ActiveRecord::Migration
  def change
    add_column :advisory_council_documents, :type, :string
  end
end
