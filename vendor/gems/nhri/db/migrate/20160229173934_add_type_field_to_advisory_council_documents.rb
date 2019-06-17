class AddTypeFieldToAdvisoryCouncilDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :advisory_council_documents, :type, :string
  end
end
