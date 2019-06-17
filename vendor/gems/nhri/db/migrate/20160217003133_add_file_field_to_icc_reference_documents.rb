class AddFileFieldToIccReferenceDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :icc_reference_documents, :file_id, :string
  end
end
