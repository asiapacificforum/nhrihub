class CorporateServices::ProjectTypesController < ProjectTypesController
  def create
    @mandate = Mandate.find_by(:key => 'corporate_services')
    super
  end

  def destroy
    @mandate = Mandate.find_by(:key => 'corporate_services')
    super
  end
end
