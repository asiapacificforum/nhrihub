class AddCounterCacheColumnToDocumentGroupsTable < ActiveRecord::Migration
  def change
    add_column :document_groups, :archive_doc_count, :integer, :default => 0
  end
end
