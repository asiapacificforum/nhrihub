class AddTypeFieldToDocumentGroupTable < ActiveRecord::Migration
  def change
    add_column :document_groups, :type, :string, :limit => 40
  end
end
