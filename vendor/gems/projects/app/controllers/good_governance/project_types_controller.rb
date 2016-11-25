class GoodGovernance::ProjectTypesController < ProjectTypesController
  def create
    @mandate = Mandate.find_by(:key => 'good_governance')
    super
  end

  def destroy
    @mandate = Mandate.find_by(:key => 'good_governance')
    super
  end
end
