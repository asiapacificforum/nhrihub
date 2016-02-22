class Nhri::AdvisoryCouncil::TermsOfReferencesController < ApplicationController
  def index
    @terms_of_reference_versions = TermsOfReferenceVersion.all
  end
end
