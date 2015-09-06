class CorporateServices::InternalDocuments::FiletypesController < ApplicationController
  def create
    filetype = CorporateServices::Filetype.create(params[:corporate_services_filetype][:ext])
    if filetype.errors.empty?
      render :text => filetype.ext, :status => 200, :content_type => 'text/plain'
    else
      render :text => filetype.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    SiteConfig['corporate_services.internal_documents.filetypes'] =
      SiteConfig['corporate_services.internal_documents.filetypes'] - [params[:type]]
    render :json => {}, :status => 200
  end
end
