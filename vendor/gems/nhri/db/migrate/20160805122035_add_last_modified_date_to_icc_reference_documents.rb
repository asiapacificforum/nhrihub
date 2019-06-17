class AddLastModifiedDateToIccReferenceDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :icc_reference_documents, :lastModifiedDate, :datetime
  end
end
