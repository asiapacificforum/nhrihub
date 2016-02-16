class CorporateServices::InternalDocuments::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def config_param
    InternalDocument::ConfigPrefix+'.filesize'
  end
end
