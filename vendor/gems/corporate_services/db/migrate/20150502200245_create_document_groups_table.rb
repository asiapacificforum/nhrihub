class CreateDocumentGroupsTable < ActiveRecord::Migration
  def change
    create_table :document_groups do |t|
      t.timestamps
    end
  end
end
