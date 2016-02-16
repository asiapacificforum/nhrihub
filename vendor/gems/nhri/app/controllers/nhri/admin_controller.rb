class Nhri::AdminController < ApplicationController
  def index
    @doc_groups = AccreditationDocumentGroup.all.map(&:title)
    @doc_group = AccreditationDocumentGroup.new
    @filetype = Nhri::Filetype.new
    @icc_reference_document_filetypes = SiteConfig['nhri.icc.filetypes']
  end
end
