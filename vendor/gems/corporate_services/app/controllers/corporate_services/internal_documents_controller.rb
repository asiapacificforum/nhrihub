class CorporateServices::InternalDocumentsController < ApplicationController
  def index
  end

  def create
    InternalDocument.create(:document => params[:files][0])
    render :json => {:files => [{:name =>params[:files][0].original_filename}]}
  end
end
