class AdvisoryCouncilDocument < ActiveRecord::Base
  include DocumentVersioning
  include FileConstraints
  include DocumentApi

  belongs_to :user
  alias_method :uploaded_by, :user

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

end
