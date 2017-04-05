class ProjectDocumentsController < ApplicationController
  include AttachedFile

  def destroy
    @project_document = ProjectDocument.find(params[:id])
    @project_document.destroy
    head :ok
  end

  def show
    send_attached_file ProjectDocument.find(params[:id])
  end
end
