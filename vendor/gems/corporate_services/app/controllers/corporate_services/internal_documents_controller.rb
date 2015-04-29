class CorporateServices::InternalDocumentsController < ApplicationController
  def index
    @internal_document = InternalDocument.new
    @internal_documents = InternalDocument.all
  end

  def create
    params["internal_document"]["original_filename"] = params[:internal_document][:file].original_filename
    internal_document = InternalDocument.create(doc_params)
    data = internal_document.presentation_attributes
    render :json => {:files => [data]} # b/c this is how jquery-fileupload-ui expects the data to be formatted
  end

  def destroy
    InternalDocument.destroy(params[:id])
    render :json => {:id => params[:id]}
  end

  def update
    doc = InternalDocument.find(params[:id])
    if doc.update(doc_params)
      render :json => doc.presentation_attributes, :status => 200
    else
      render :nothing => true, :status => 500
    end
  rescue
    render :nothing => true, :status => 500
  end

  private
  def doc_params
    params.require(:internal_document).permit(:title, :revision, :file, :original_filename, :original_type, :lastModifiedDate, :filesize)
  end
end
