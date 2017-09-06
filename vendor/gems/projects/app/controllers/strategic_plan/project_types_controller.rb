class StrategicPlan::ProjectTypesController < ProjectTypesController
  def create
    @mandate = Mandate.find_by(:key => 'strategic_plan')
    super
  end

  def destroy
    @mandate = Mandate.find_by(:key => 'strategic_plan')
    super
  end
end
