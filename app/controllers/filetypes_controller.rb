class FiletypesController < ApplicationController
  def create
    filetype = Filetype.create(params[:filetype],model)
    if filetype.errors.empty?
      render :plain => filetype.ext, :status => 200, :content_type => 'text/plain'
    else
      render :js => "flash.set('error_message', '#{filetype.errors.full_messages.first}');flash.notify();", :status => 422
    end
  end

  def destroy
    config_param = model.filetypes_config_param
    SiteConfig[config_param] = SiteConfig[config_param] - [params[:ext]]
    render :json => {}, :status => 200
  end

end
