class AddDocumentToInternalDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :document_id, :string
  end
end
