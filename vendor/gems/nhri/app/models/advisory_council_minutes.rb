class AdvisoryCouncilMinutes < AdvisoryCouncilDocument
  ConfigPrefix = 'nhri.advisory_council_minutes'

  def title
    # in config/locales/models/terms_of_reference_version/en.yml
    self.class.model_name.human(:date => created_at.to_s(:default))
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.nhri_advisory_council_minutes_path(I18n.locale, self)
    end
  end
end
