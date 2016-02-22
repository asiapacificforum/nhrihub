class Nhri::Icc::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def config_param
    IccReferenceDocument::ConfigPrefix+'.filetypes'
  end

  def attrs
    params[:filetype].merge!(:model => IccReferenceDocument)
  end

  def delete_key
    params[:type]
  end
end
