class Nhri::Icc::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def model
    IccReferenceDocument
  end
end
