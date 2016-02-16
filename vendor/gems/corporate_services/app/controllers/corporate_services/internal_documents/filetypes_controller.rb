class CorporateServices::InternalDocuments::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def klass
    CorporateServices::Filetype
  end

  def param
    params[:corporate_services_filetype][:ext]
  end

  def delete_key
    params[:type]
  end
end
