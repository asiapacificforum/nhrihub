class AddFileFieldsFromClientToInternalDocuments < ActiveRecord::Migration
  def change
    add_column :internal_documents, :lastModifiedDate, :datetime
    add_column :internal_documents, :original_type, :string
  end
end
