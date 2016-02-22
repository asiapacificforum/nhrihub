class OutreachMedia::AdminController < ApplicationController
  def index
    @outreach_filetypes = SiteConfig['outreach_event.filetypes']
    @outreach_filetype = Filetype.new
    @media_filetypes = SiteConfig['media_appearance.filetypes']
    @media_filetype = Filetype.new
    @outreach_filesize = SiteConfig['outreach_event.filesize']
    @media_filesize = SiteConfig['media_appearance.filesize']
    @areas = Area.all
    @subarea = Subarea.new
    @audience_type = AudienceType.new
    @audience_types = AudienceType.all
  end
end
