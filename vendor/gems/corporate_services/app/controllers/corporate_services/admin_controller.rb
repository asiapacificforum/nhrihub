class CorporateServices::AdminController < ApplicationController
  def index
    @internal_document_filetypes = SiteConfig['corporate_services.internal_documents.filetypes']
    @filetype = Filetype.new
    @filesize = SiteConfig['corporate_services.internal_documents.filesize']
    @start_date = StrategicPlanStartDate.new
  end
end
