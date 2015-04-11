class CorporateServices::InternalDocumentsController < ApplicationController
  def index
    render :upload
  end

  def create
    render :json => {:files => [{:name => "kablooie"}, {:name => "kablonka"}]}
  end
end
