class AddDocumentToInternalDocuments < ActiveRecord::Migration
  def change
    add_column :internal_documents, :document_id, :string
  end
end
