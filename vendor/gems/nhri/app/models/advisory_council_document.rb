class AdvisoryCouncilDocument < ActiveRecord::Base
  include DocumentVersioning
  include FileConstraints
  include DocumentApi

  belongs_to :user
  alias_method :uploaded_by, :user

  attachment :file

  before_save do |doc|
    doc.receives_next_major_rev if doc.revision.blank?
  end

  def date
    created_at.to_date.to_s(:short)
  end

  def date=(val)
    self.created_at = val.blank? ? DateTime.now : DateTime.parse(val)
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:title,
                       :revision,
                       :uploaded_by,
                       #:url,
                       :date,
                       :formatted_modification_date,
                       :formatted_creation_date,
                       :formatted_filesize ] )
  end

end
