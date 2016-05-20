class Siu::ComplaintsController < ComplaintsController
  def index
    @model = Siu::Complaint
    super
  end
end
