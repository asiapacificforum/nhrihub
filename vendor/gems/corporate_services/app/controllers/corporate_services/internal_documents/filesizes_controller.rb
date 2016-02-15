class CorporateServices::InternalDocuments::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def config_param
    'corporate_services.internal_documents.filesize'
  end

end
