class ComplaintAdminController < ApplicationController
  def show
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
    @complaint_category = ComplaintCategory.new
    @complaint_categories = ComplaintCategory.pluck(:name)
  end
end
