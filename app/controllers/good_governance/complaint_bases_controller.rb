class GoodGovernance::ComplaintBasesController < ComplaintBasesController
  def create
    @model = GoodGovernance::ComplaintBasis
    super
  end

  def destroy
    @model = GoodGovernance::ComplaintBasis
    super
  end

  private
  def complaint_basis_params
    params.require(:good_governance_complaint_basis).permit(:name)
  end
end
