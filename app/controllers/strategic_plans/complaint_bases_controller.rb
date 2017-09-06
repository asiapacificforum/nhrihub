class StrategicPlans::ComplaintBasesController < ComplaintBasesController
  def create
    @model = StrategicPlans::ComplaintBasis
    super
  end

  def destroy
    @model = StrategicPlans::ComplaintBasis
    super
  end

  private
  def complaint_basis_params
    params.require(:strategic_plans_complaint_basis).permit(:name)
  end
end
