require 'icc_reference_document' # why? don't know, but without it Ruby fails to find the IccReferenceDocument constant!

class Nhri::IccReferenceDocumentsController < ApplicationController
  include AttachedFile

  def index
    @icc_reference_document  = IccReferenceDocument.new
    @icc_reference_documents = IccReferenceDocument.all
  end

  def create
    params["icc_reference_document"]["user_id"] = current_user.id
    @reference_document = IccReferenceDocument.create(doc_params)
    render :json => {:file => @reference_document}
  end

  def update
    icc_reference_document = IccReferenceDocument.find(params[:id])
    if icc_reference_document.update(doc_params)
      render :json => icc_reference_document, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    doc = IccReferenceDocument.find(params[:id])
    doc.destroy
    head :ok
  end

  def show
    send_attached_file IccReferenceDocument.find(params[:id])
  end

  private

  def doc_params
    attrs = [:title, :revision, :file, :original_filename,
             :original_type, :lastModifiedDate, :filesize,
             :user_id, :source_url]
    params.
      require(:icc_reference_document).
      permit(*attrs)
  end
end
