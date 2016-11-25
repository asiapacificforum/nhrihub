class Siu::ProjectTypesController < ProjectTypesController
  def create
    @mandate = Mandate.find_by(:key => 'special_investigations_unit')
    super
  end

  def destroy
    @mandate = Mandate.find_by(:key => 'special_investigations_unit')
    super
  end
end
