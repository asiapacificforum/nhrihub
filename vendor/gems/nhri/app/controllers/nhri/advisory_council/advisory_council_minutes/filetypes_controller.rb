require 'nhri/advisory_council/advisory_council_minutes'
class Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes::FiletypesController < FiletypesController
  def create
    super
  end

  def destroy
    super
  end

  private
  def model
    Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes
  end
end
