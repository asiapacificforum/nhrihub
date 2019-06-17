class AddDocumentAttributesToInternalDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :title, :string
    add_column :internal_documents, :filesize, :integer
    add_column :internal_documents, :original_filename, :string
    add_column :internal_documents, :revision_major, :integer
    add_column :internal_documents, :revision_minor, :integer
    rename_column :internal_documents, :document_id, :file_id
    add_timestamps :internal_documents
  end
end
