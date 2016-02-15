class Nhri::Icc::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def config_param
    'nhri.icc.filesize'
  end

end
