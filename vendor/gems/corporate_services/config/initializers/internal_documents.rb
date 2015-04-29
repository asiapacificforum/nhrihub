InternalDocument.upload_document_attributes =
  { :acceptFileTypes => [:pdf, :doc, :docx],
    :maxFileSize => 3000000
  }

if Rails.env.development? || Rails.env.test?
  factory_path = Rails.root.join('vendor','gems','corporate_services','spec','factories')
  FactoryGirl.definition_file_paths << factory_path
end
