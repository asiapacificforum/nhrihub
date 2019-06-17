class IncreaseLengthOfInternalDocumentsTypeField < ActiveRecord::Migration[4.2]
  def change
    change_column :internal_documents, :type, :string, :limit => 60
  end
end
