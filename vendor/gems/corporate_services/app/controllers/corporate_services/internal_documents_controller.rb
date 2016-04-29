class CorporateServices::InternalDocumentsController < InternalDocumentsController
  def index
    @internal_document = CorporateServices::InternalDocument.new
    @internal_documents = DocumentGroup.non_empty.map(&:primary) # all types of InternalDocument
    @required_files_titles = AccreditationDocumentGroup.all.map(&:id_and_title)
    @model_name = CorporateServices::InternalDocument.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')+'.index'
    render 'internal_documents/index'
  end
end
