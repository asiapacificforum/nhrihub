class Siu::ComplaintBasesController <  ComplaintBasesController
  def create
    @model = Siu::ComplaintBasis
    super
  end

  def destroy
    @model = Siu::ComplaintBasis
    super
  end

  private
  def complaint_basis_params
    params.require(:siu_complaint_basis).permit(:name)
  end
end
