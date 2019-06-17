class AddCounterCacheColumnToDocumentGroupsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :document_groups, :archive_doc_count, :integer, :default => 0
  end
end
