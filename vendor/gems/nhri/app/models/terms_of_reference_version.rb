class TermsOfReferenceVersion < ActiveRecord::Base
  include DocumentVersioning
  include FileConstraints
  include DocumentApi

  belongs_to :user

  ConfigPrefix = 'nhri.terms_of_reference_version'

  attachment :file

  default_scope ->{ order(:revision_major, :revision_minor) }

  def as_json(options={})
    super(:except => [:created_at, :updated_at], :methods => :title)
  end

  def title
    self.class.model_name.human(:revision => revision)
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.nhri_advisory_council_terms_of_reference_path(I18n.locale, self)
    end
  end
end
