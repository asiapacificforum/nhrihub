class CorporateServices::InternalDocumentsController < ApplicationController
  def index
    @internal_document = InternalDocument.new
    @internal_documents = InternalDocument.primary
  end

  def create
    params["internal_document"]["original_filename"] = params[:internal_document][:file].original_filename
    internal_document = InternalDocument.create(doc_params)
    data = internal_document.presentation_attributes
    render :json => {:files => [data]} # b/c this is how jquery-fileupload-ui expects the data to be formatted
  end

  def destroy
    doc = InternalDocument.find(params[:id])
    if doc.primary? && doc.has_archive_files?
      # doc being deleted is primary with archive
      # so promote an inheritor
      new_primary = doc.inheritor.promoted
      InternalDocument.destroy(params[:id])
      render :json => new_primary.presentation_attributes
    else
      # delete it and move on
      InternalDocument.destroy(params[:id])
      render :json => {:id => params[:id]}
    end
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

  def show
    internal_document = InternalDocument.find(params[:id])
    send_opts = { :filename => internal_document.original_filename,
                  :type => internal_document.original_type,
                  :disposition => :attachment }
    send_file internal_document.file.to_io, send_opts
  end

  private
  def doc_params
    params.
      require(:internal_document).
      permit(:title, :revision, :file, :original_filename, :original_type, :lastModifiedDate, :filesize)
  end
end
