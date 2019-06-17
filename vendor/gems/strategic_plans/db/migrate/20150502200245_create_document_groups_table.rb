class CreateDocumentGroupsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :document_groups, :force => true do |t|
      t.timestamps
    end
  end
end
