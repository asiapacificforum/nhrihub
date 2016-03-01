class Nhri::AdvisoryCouncil::TermsOfReferenceVersion < AdvisoryCouncilDocument
  ConfigPrefix = 'nhri.terms_of_reference_version'

  default_scope ->{ order(:revision_major => :desc, :revision_minor => :desc) }

  def title
    # in config/locales/models/terms_of_reference_version/en.yml
    self.class.model_name.human(:revision => revision)
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.nhri_advisory_council_terms_of_reference_path(I18n.locale, self)
    end
  end
end
