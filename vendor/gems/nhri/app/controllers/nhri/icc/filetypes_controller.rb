class Nhri::Icc::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def klass
    Nhri::Filetype
  end

  def param
    params[:nhri_filetype][:ext]
  end

  def delete_key
    params[:type]
  end
end
