class Nhri::AdvisoryCouncil::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def config_param
    TermsOfReferenceVersion::ConfigPrefix+'.filetypes'
  end

  def attrs
    params[:filetype].merge!(:model => TermsOfReferenceVersion)
  end

  def delete_key
    params[:type]
  end
end
