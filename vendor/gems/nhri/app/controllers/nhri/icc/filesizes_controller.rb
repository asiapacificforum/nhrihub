class Nhri::Icc::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def config_param
    IccReferenceDocument::ConfigPrefix+'.filesize'
  end
end
