class OutreachMedia::AdminController < ApplicationController
  # NOTE OutreachEvent and MediaAppearances share the same config variables
  def index
    #@outreach_filetypes = SiteConfig['outreach_event.filetypes']
    @outreach_filetypes = OutreachEvent.filetypes
    @outreach_filetype = Filetype.new
    #@media_filetypes = SiteConfig['media_appearance.filetypes']
    @media_filetypes = OutreachEvent.filetypes
    @media_filetype = Filetype.new
    #@outreach_filesize = SiteConfig['outreach_event.filesize']
    @outreach_filesize = OutreachEvent.maximum_filesize
    #@media_filesize = SiteConfig['media_appearance.filesize']
    @media_filesize = OutreachEvent.maximum_filesize
    @areas = Area.all
    @subarea = Subarea.new
    @audience_type = AudienceType.new
    @audience_types = AudienceType.all
  end
end
