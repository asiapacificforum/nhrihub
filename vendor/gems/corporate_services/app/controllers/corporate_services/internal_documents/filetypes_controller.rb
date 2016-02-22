class CorporateServices::InternalDocuments::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def config_param
    InternalDocument::ConfigPrefix+'.filetypes'
  end

  def attrs
    params[:filetype].merge!(:model => InternalDocument)
  end

  def delete_key
    params[:type]
  end
end
