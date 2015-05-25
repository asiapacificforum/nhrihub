class AddUserIdToInternalDocumentsTable < ActiveRecord::Migration
  def change
    add_column :internal_documents, :user_id, :integer
  end
end
