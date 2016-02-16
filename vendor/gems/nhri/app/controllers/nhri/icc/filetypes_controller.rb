class Nhri::Icc::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def klass
    Nhri::Filetype
  end

  def param
    params[:corporate_services][:ext]
  end

  def config_param
    'corporate_services.internal_documents.filetypes'
  end

  def delete_key
    params[:type]
  end
end
