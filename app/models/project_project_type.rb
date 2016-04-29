class ProjectProjectType < ActiveRecord::Base
  belongs_to :project
  belongs_to :project_type
end
