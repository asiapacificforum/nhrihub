class AddDocumentGroupIdToInternalDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :document_group_id, :integer
  end
end
