class AddRefileMetadataColumnsToOutreachEventDocuments < ActiveRecord::Migration
  def change
    rename_column :outreach_event_documents, 'filesize', 'file_size'
    rename_column :outreach_event_documents, 'original_filename', 'file_filename'
    rename_column :outreach_event_documents, 'original_type', 'file_content_type'
  end
end
