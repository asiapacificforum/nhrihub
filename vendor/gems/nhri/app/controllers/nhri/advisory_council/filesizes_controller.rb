class Nhri::AdvisoryCouncil::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def config_param
    TermsOfReferenceVersion::ConfigPrefix+'.filesize'
  end
end
