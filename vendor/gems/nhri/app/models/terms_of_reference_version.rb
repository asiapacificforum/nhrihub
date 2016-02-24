class TermsOfReferenceVersion < ActiveRecord::Base
  include DocumentVersioning
  include FileConstraints
  include DocumentApi

  belongs_to :user
  alias_method :uploaded_by, :user

  ConfigPrefix = 'nhri.terms_of_reference_version'

  attachment :file

  default_scope ->{ order(:revision_major => :desc, :revision_minor => :desc) }

  before_save do |doc|
    doc.receives_next_major_rev if doc.revision.blank?
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:title,
                       :revision,
                       :uploaded_by,
                       :url,
                       :formatted_modification_date,
                       :formatted_creation_date,
                       :formatted_filesize ] )
  end

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
