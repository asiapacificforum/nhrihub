class Nhri::ComplaintsController < ComplaintsController
  def index
    @model = Nhri::Complaint
    super
  end
end
