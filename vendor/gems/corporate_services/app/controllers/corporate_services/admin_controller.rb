class CorporateServices::AdminController < ApplicationController
  def index
    @internal_document_filetypes = InternalDocument.permitted_filetypes
    @filetype = CorporateServices::Filetype.new
    @filesize = InternalDocument.maximum_filesize / 1000000
    @start_date = StrategicPlanStartDate.new
  end
end
