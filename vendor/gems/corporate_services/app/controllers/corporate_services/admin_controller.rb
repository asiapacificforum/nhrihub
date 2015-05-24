class CorporateServices::AdminController < ApplicationController
  def index
    @internal_document_filetypes = SiteConfig['corporate_services.internal_documents.filetypes']
    @filetype = Filetype.new
  end
end
