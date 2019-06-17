class AddTypeFieldToDocumentGroupTable < ActiveRecord::Migration[4.2]
  def change
    add_column :document_groups, :type, :string, :limit => 40
  end
end
