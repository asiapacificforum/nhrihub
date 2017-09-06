class AddTypeFieldToInternalDocumentsTable < ActiveRecord::Migration
  def change
    add_column :internal_documents, :type, :string, :limit => 40
  end
end
