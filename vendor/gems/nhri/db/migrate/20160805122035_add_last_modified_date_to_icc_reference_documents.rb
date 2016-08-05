class AddLastModifiedDateToIccReferenceDocuments < ActiveRecord::Migration
  def change
    add_column :icc_reference_documents, :lastModifiedDate, :datetime
  end
end
