require 'project_document'

class GoodGovernance::AdminController < ApplicationController
  def index
    @project_document_filetypes = ProjectDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = ProjectDocument.maximum_filesize
  end
end
