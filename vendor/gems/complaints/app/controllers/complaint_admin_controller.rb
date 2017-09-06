class ComplaintAdminController < ApplicationController
  def show
    @agency = Agency.new
    @agencies = Agency.all.to_json(:only => [:name, :full_name, :id], :methods => [:delete_allowed])
    @complaint_document_filetypes = ComplaintDocument.permitted_filetypes
    @complaint_filetype = Filetype.new
    @complaint_filesize = ComplaintDocument.maximum_filesize
    @communication_document_filetypes = CommunicationDocument.permitted_filetypes
    @communication_filetype = Filetype.new
    @communication_filesize = CommunicationDocument.maximum_filesize
    @good_governance_complaint_basis = GoodGovernance::ComplaintBasis.new
    @good_governance_complaint_bases = GoodGovernance::ComplaintBasis.pluck(:name)
    @siu_complaint_basis = Siu::ComplaintBasis.new
    @siu_complaint_bases = Siu::ComplaintBasis.pluck(:name)
    @strategic_plan_complaint_basis = StrategicPlans::ComplaintBasis.new
    @strategic_plan_complaint_bases = StrategicPlans::ComplaintBasis.pluck(:name)
  end
end
