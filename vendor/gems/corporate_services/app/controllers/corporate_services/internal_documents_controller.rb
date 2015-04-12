class CorporateServices::InternalDocumentsController < ApplicationController
  def index
  end

  def create
    render :json => {:files => [{:name =>params[:files][0].original_filename}]}
  end
end
