class Nhri::IccController < CorporateServices::InternalDocumentsController
  def index
    @internal_document = AccreditationRequiredDoc.new
    @internal_documents = AccreditationDocumentGroup.all.map(&:primary)
    @required_files_titles = AccreditationDocumentGroup.all_possible
  end
end
