class OutreachMedia::AdminController < ApplicationController
  def index
    @outreach_media_filetypes = SiteConfig['outreach_media.media_appearances.filetypes']
    @filetype = OutreachMedia::Filetype.new
    @filesize = SiteConfig['outreach_media.media_appearances.filesize']
  end
end
