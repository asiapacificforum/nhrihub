class Nhri::AdminController < ApplicationController
  def index
    @doc_groups = AccreditationDocumentGroup.all.map(&:title)
    @doc_group = AccreditationDocumentGroup.new
    @icc_reference_doc_filetype = Filetype.new
    @icc_reference_document_filetypes = IccReferenceDocument.permitted_filetypes
    @icc_reference_document_filesize = IccReferenceDocument.maximum_filesize
    @terms_of_reference_doc_filetype = Filetype.new
    @terms_of_reference_version_filetypes = TermsOfReferenceVersion.permitted_filetypes
    @terms_of_reference_version_filesize = TermsOfReferenceVersion.maximum_filesize
    @advisory_council_minutes_filetype = Filetype.new
    @advisory_council_minutes_filetypes = AdvisoryCouncilMinutes.permitted_filetypes
    @advisory_council_minutes_filesize = AdvisoryCouncilMinutes.maximum_filesize
  end
end
