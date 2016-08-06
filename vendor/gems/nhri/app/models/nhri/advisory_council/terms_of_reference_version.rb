class Nhri::AdvisoryCouncil::TermsOfReferenceVersion < AdvisoryCouncilDocument
  ConfigPrefix = 'nhri.terms_of_reference_version'

  default_scope ->{ order(:revision_major => :desc, :revision_minor => :desc) }

  def title
    # in config/locales/models/terms_of_reference_version/en.yml
    self.class.model_name.human(:revision => revision)
  end

end
