class InternalDocuments::FilesizesController < FilesizesController
  def update
    super
  end

  private
  def model
    InternalDocument
  end
end
