class CommunicationDocumentsController < ApplicationController
  include AttachedFile

  def destroy
    @communication_document = CommunicationDocument.find(params[:id])
    @communication_document.destroy
    head :ok
  end

  def show
    send_attached_file CommunicationDocument.find(params[:id])
  end
end
