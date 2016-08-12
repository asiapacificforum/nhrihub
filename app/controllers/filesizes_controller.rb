class FilesizesController < ApplicationController

  def update
    if params[:filesize].match(/^\d+$/) && params[:filesize].to_i < 100
      SiteConfig[model.filesize_config_param] = params[:filesize].to_i
      render :plain => params[:filesize], :status => 200
    else
      head :ok
    end
  end

end
