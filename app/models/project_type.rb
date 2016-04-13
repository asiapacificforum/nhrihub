class ProjectType < ActiveRecord::Base
  belongs_to :project
  belongs_to :type
end
