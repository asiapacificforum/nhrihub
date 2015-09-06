class OutreachMedia::MediaAppearances::FilesizesController < ApplicationController

  def update
    if params[:filesize].match(/^\d+$/) && params[:filesize].to_i < 100
      SiteConfig['outreach_media.media_appearances.filesize'] = params[:filesize].to_i
      render :text => params[:filesize], :status => 200
    else
      render :nothing => true, :status => 200
    end
  end

end
