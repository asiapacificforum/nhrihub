class ProjectDocument < ActiveRecord::Base
  attachment :file

  def as_json(options={})
    super(:except => [:updated_at, :created_at])
  end
end
