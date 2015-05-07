json.files do
  json.array! [@internal_document] do |internal_document|
    attrs = [:id,
             :title,
             :original_filename,
             :original_type,
             :revision]

    json.(internal_document, *attrs)
    json.url corporate_services_internal_document_path(I18n.locale, internal_document)
    json.deleteUrl corporate_services_internal_document_path(I18n.locale, internal_document)
    json.formatted_modification_date internal_document.lastModifiedDate.to_s
    json.formatted_creation_date internal_document.created_at.to_s
    json.formatted_filesize number_to_human_size(internal_document.filesize)

    json.archive_files internal_document.archive_files do |archive|
      json.(archive, *attrs)
    end
  end
end
