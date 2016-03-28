class Nhri::FileMonitor::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def model
    Nhri::FileMonitor
  end
end
