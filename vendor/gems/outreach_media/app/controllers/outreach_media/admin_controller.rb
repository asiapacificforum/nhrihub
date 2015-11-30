class OutreachMedia::AdminController < ApplicationController
  def index
    @outreach_media_filetypes = SiteConfig['outreach_media.filetypes']
    @filetype = OutreachMedia::Filetype.new
    @filesize = SiteConfig['outreach_media.filesize']
    @areas = Area.all
    @subarea = Subarea.new
  end
end
