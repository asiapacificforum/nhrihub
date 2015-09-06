class OutreachMedia::MediaAppearances::FiletypesController < ApplicationController
  def create
    filetype = OutreachMedia::Filetype.create(params[:outreach_media_filetype][:ext])
    if filetype.errors.empty?
      render :text => filetype.ext, :status => 200, :content_type => 'text/plain'
    else
      render :text => filetype.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    SiteConfig['outreach_media.media_appearances.filetypes'] =
      SiteConfig['outreach_media.media_appearances.filetypes'] - [params[:type]]
    render :json => {}, :status => 200
  end
end
