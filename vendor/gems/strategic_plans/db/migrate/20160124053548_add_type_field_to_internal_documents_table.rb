class AddTypeFieldToInternalDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :type, :string, :limit => 40
  end
end
