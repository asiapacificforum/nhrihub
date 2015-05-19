class CorporateServices::InternalDocumentsController < ApplicationController
  def index
    @internal_document = InternalDocument.new
    @internal_documents = DocumentGroup.all.map(&:primary)
  end

  def create
    params["internal_document"]["original_filename"] = params[:internal_document][:file].original_filename
    @internal_documents = [InternalDocument.create(doc_params)]
    render :layout => false # see jbuilder template in views
  end

  def destroy
    doc = InternalDocument.find(params[:id])
    document_group = doc.document_group
    doc.destroy
    @internal_document = document_group.primary
    if @internal_document
      render :partial => 'internal_document', :layout => false, :locals => {:internal_document => @internal_document}
    else
      # document group is now empty
      render :json => {:deleted_id => params[:id]}
    end
  end

  def update
    internal_document = InternalDocument.find(params[:id])
    # copy the filename from the file object, if it's present
    if params[:internal_document][:archive_files]
      params["internal_document"][:archive_files][0]["original_filename"] =
        params[:internal_document][:archive_files][0][:file].original_filename
    end
    if internal_document.update(doc_params)
      # return the primary, even if we're updating an archive doc
      @internal_document = internal_document.document_group_primary
      # it's a jbuilder partial
      render :layout => false, :status => 200
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
      permit(:title, :revision, :file, :original_filename, :original_type,
             :lastModifiedDate, :filesize, :primary,
             :archive_files =>[:title, :revision, :file, :original_filename, :original_type,
             :lastModifiedDate, :filesize, :primary, :document_group_id])
  end
end
