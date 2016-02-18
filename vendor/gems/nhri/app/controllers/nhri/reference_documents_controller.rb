class Nhri::ReferenceDocumentsController < ApplicationController
  def index
    @icc_reference_document = IccReferenceDocument.new
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
      render :nothing => true, :status => 500
    end
  end

  def destroy
    doc = IccReferenceDocument.find(params[:id])
    doc.destroy
    render :nothing => true, :status => 200
  end

  def show
    doc = IccReferenceDocument.find(params[:id])
    send_opts = { :filename => doc.original_filename,
                  :type => doc.original_type,
                  :disposition => :attachment }
    send_file doc.file.to_io, send_opts
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
