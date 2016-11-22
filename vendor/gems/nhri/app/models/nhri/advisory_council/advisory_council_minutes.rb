class Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes < AdvisoryCouncilDocument
  ConfigPrefix = 'nhri.advisory_council_minutes'

  default_scope ->{ order(:date => :desc) }

  def title
    # in config/locales/models/advisory_council_minutes/en.yml
    self.class.model_name.human(:date => date.to_date.to_s(:default))
  end

end
