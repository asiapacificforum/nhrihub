class AddFileFieldToIccReferenceDocuments < ActiveRecord::Migration
  def change
    add_column :icc_reference_documents, :file_id, :string
  end
end
