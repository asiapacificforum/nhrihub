class CorporateServices::ComplaintBasesController < ComplaintBasesController
  def create
    @model = CorporateServices::ComplaintBasis
    super
  end

  def destroy
    @model = CorporateServices::ComplaintBasis
    super
  end

  private
  def complaint_basis_params
    params.require(:corporate_services_complaint_basis).permit(:name)
  end
end
