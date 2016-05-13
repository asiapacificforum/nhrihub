class ProjectDocument < ActiveRecord::Base
  include FileConstraints

  ConfigPrefix = 'project_document'

  attachment :file

  def as_json(options={})
    super(:except => [:updated_at, :created_at])
  end
end
