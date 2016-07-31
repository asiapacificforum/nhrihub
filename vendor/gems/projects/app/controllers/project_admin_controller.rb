class ProjectAdminController < ApplicationController
  def show
    @project_document_filetypes = ProjectDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = ProjectDocument.maximum_filesize
    @project_type = ProjectType.new
    @project_types = Mandate.project_types.all.map(&:name)
  end
end
