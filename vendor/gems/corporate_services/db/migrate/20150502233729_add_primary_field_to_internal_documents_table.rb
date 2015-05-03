class AddPrimaryFieldToInternalDocumentsTable < ActiveRecord::Migration
  def change
    add_column :internal_documents, :primary, :boolean, :default => false
  end
end
