class FiletypesController < ApplicationController
  def create
    filetype = klass.send(:create,param)
    if filetype.errors.empty?
      render :text => filetype.ext, :status => 200, :content_type => 'text/plain'
    else
      render :text => filetype.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    SiteConfig[config_param] = SiteConfig[config_param] - [delete_key]
    render :json => {}, :status => 200
  end
end
