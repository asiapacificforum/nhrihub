class AddFileFieldsFromClientToInternalDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :lastModifiedDate, :datetime
    add_column :internal_documents, :original_type, :string
  end
end
