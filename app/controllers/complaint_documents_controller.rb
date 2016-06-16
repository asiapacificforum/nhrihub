class ComplaintDocumentsController < ApplicationController
  def destroy
    @complaint_document = ComplaintDocument.find(params[:id])
    @complaint_document.destroy
    render :nothing => true, :status => 200
  end

  def show
    complaint_document = ComplaintDocument.find(params[:id])
    send_opts = { :filename => complaint_document.filename,
                  :type => complaint_document.original_type,
                  :disposition => :attachment }
    send_file complaint_document.file.to_io, send_opts
  end
end
