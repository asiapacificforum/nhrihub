class IncreaseLengthOfInternalDocumentsTypeField < ActiveRecord::Migration
  def change
    change_column :internal_documents, :type, :string, :limit => 60
  end
end
