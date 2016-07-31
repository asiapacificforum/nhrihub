class ProjectDocument < ActiveRecord::Base
  include FileConstraints

  ConfigPrefix = 'project_document'

  attachment :file

  # hard-coded for now, maybe should be user-configurable? later dude!
  NamedProjectDocumentTitles = ["Project Document", "Analysis", "Final Report"]

  scope :named, ->{where(:title => NamedProjectDocumentTitles )}

  def as_json(options={})
    super(:except => [:updated_at, :created_at])
  end

  def named?
    NamedProjectDocumentTitles.include?(title)
  end

  def not_named?
    !named?
  end
end
