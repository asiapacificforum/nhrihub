class CorporateServices::InternalDocumentsController < ApplicationController
  def index
    @internal_document = InternalDocument.new
    @internal_documents = DocumentGroup.all.map(&:primary)
    @required_files_titles = AccreditationRequiredDoc::DocTitles
  end

  def create
    params["internal_document"]["original_filename"] = params[:internal_document][:file].original_filename
    params["internal_document"]["user_id"] = current_user.id
    @internal_document = InternalDocument.create(doc_params)
    render :json => @internal_document
  end

  def destroy
    doc = InternalDocument.find(params[:id])
    document_group_id = doc.document_group_id
    doc.destroy
    unless DocumentGroup.exists?(document_group_id)
      render :nothing => true, :status => 205
    else
      internal_document = DocumentGroup.find(document_group_id).primary
      render :json => internal_document, :status => 200
    end
  end

  # update invoked for updating the original_filename and/or revision
  # also invoked for adding replacing a file... updating the document group
  def update
    internal_document = InternalDocument.find(params[:id])
    if internal_document.update(doc_params)
      # return the primary, even if we're updating an archive doc
      @internal_document = internal_document.document_group_primary
      # it's a jbuilder partial
      #render :layout => false, :status => 200
      render :json => @internal_document, :status => 200
    else
      render :nothing => true, :status => 500
    end
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
    attrs = [:title, :revision, :file, :original_filename,
             :original_type, :lastModifiedDate, :filesize,
             :document_group_id, :user_id]
    params.
      require(:internal_document).
      #permit(*attrs, :archive_files =>[*attrs])
      permit(*attrs)
  end
end
