class OutreachMedia::FilesizesController < FilesizesController

  def update
    super
  end

  private
  def config_param
    'outreach_event.filesize'
  end

end
