class HumanRights::ProjectTypesController < ProjectTypesController
  def create
    @mandate = Mandate.find_by(:key => 'human_rights')
    super
  end

  def destroy
    @mandate = Mandate.find_by(:key => 'human_rights')
    super
  end
end
