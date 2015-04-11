class CorporateServices::InternalDocumentsController < ApplicationController
  def index
  end

  def create
    render :json => {:files => [{:name => "kablooie"}, {:name => "kablonka"}]}
  end
end
