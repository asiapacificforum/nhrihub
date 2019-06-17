class CreateInternalDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :internal_documents, :force => true
  end
end
