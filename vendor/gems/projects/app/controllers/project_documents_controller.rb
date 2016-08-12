class ProjectDocumentsController < ApplicationController
  def destroy
    @project_document = ProjectDocument.find(params[:id])
    @project_document.destroy
    head :ok
  end

  def show
    project_document = ProjectDocument.find(params[:id])
    send_opts = { :filename => project_document.filename,
                  :type => project_document.original_type,
                  :disposition => :attachment }
    send_file project_document.file.to_io, send_opts
  end
end
