class CorporateServices::InternalDocuments::FiletypesController < ApplicationController
  def create
    if match = params[:filetype][:ext].match(/\w+/) # eliminate punctuation, spaces etc
      filetype  = match[0].downcase
      filetypes = SiteConfig['corporate_services.internal_documents.filetypes'] << filetype
      filetypes = SiteConfig['corporate_services.internal_documents.filetypes'] = filetypes.uniq
    end
    render :text => filetype, :status => 200, :content_type => 'text/plain'
  end

  def destroy
    SiteConfig['corporate_services.internal_documents.filetypes'] =
      SiteConfig['corporate_services.internal_documents.filetypes'] - [params[:type]]
    render :nothing => true, :status => 200
  end
end
