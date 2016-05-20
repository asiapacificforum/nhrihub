class GoodGovernance::ComplaintsController < ComplaintsController
  def index
    @model = GoodGovernance::Complaint
    super
  end
end
