class AddUserIdToInternalDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :internal_documents, :user_id, :integer
  end
end
