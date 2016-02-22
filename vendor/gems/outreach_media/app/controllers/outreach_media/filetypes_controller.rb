class OutreachMedia::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def config_param
    'outreach_event.filetypes'
  end

  def attrs
    params[:filetype].merge!(:model => OutreachEvent)
  end

  def delete_key
    params[:type]
  end
end
