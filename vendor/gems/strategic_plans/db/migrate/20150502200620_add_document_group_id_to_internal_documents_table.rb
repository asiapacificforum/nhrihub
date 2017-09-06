class AddDocumentGroupIdToInternalDocumentsTable < ActiveRecord::Migration
  def change
    add_column :internal_documents, :document_group_id, :integer
  end
end
