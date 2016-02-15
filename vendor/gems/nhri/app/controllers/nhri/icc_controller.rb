class Nhri::IccController < CorporateServices::InternalDocumentsController
  def index
    @internal_document = AccreditationRequiredDoc.new
    @internal_documents = AccreditationDocumentGroup.all.map(&:primary)
    @required_files_titles = AccreditationDocumentGroup.all.map(&:id_and_title)
  end
end
