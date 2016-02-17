class Nhri::AdminController < ApplicationController
  def index
    @doc_groups = AccreditationDocumentGroup.all.map(&:title)
    @doc_group = AccreditationDocumentGroup.new
    @filetype = Nhri::Filetype.new
    @icc_reference_document_filetypes = IccReferenceDocument.permitted_filetypes
    @filesize = IccReferenceDocument.maximum_filesize / 1000000
  end
end
