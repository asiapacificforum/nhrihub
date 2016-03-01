class Nhri::AdminController < ApplicationController
  def index
    @doc_groups = AccreditationDocumentGroup.all.map(&:title)
    @doc_group = AccreditationDocumentGroup.new
    @icc_reference_doc_filetype = Filetype.new
    @icc_reference_document_filetypes = IccReferenceDocument.permitted_filetypes
    @icc_reference_document_filesize = IccReferenceDocument.maximum_filesize
    @terms_of_reference_doc_filetype = Filetype.new
    @terms_of_reference_version_filetypes = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.permitted_filetypes
    @terms_of_reference_version_filesize = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.maximum_filesize
    @advisory_council_minutes_filetype = Filetype.new
    @advisory_council_minutes_filetypes = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.permitted_filetypes
    @advisory_council_minutes_filesize = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.maximum_filesize
  end
end
