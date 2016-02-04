require_relative './seed_data'

SeedData.initialize

MagicLamp.define do
  # e.g. on page do this:  window.internal_document_data = MagicLamp.loadJSON('internal_document_data')
  fixture(:name => 'internal_document_data') do
    DocumentGroup.all.map(&:primary)
  end

  fixture(:name => 'new_internal_document') do
    InternalDocument.new
  end

  fixture(:name => 'required_files_titles') do
    AccreditationRequiredDoc::DocTitles
  end

  fixture(:name => 'internal_document_maximum_filesize') do
    InternalDocument.maximum_filesize
  end

  fixture(:name => 'internal_document_permitted_filetypes') do
    InternalDocument.permitted_filetypes
  end

  fixture(:name => 'internal_document_page') do
    render :partial => 'corporate_services/internal_documents/index'
  end

  fixture(:name => 'no_files_error_message') do
    "No files"
  end
end
