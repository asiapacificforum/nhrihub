class OutreachMedia::FilesizesController < FilesizesController

  def update
    super
  end

  private
  def model
    OutreachEvent
  end
end
