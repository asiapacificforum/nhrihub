class InternalDocumentAdminController < ApplicationController
  def show
    @internal_document_filetypes = InternalDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = InternalDocument.maximum_filesize
  end
end
