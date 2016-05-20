class ProjectAdminController < ApplicationController
  def show
    @project_document_filetypes = ProjectDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = ProjectDocument.maximum_filesize
  end
end
