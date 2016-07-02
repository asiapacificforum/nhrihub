class CommunicationDocumentsController < ApplicationController
  def destroy
    @communication_document = CommunicationDocument.find(params[:id])
    @communication_document.destroy
    render :nothing => true, :status => 200
  end

  def show
    communication_document = CommunicationDocument.find(params[:id])
    send_opts = { :filename => communication_document.filename,
                  :type => communication_document.original_type,
                  :disposition => :attachment }
    send_file communication_document.file.to_io, send_opts
  end
end
