class ProjectConvention < ActiveRecord::Base
  belongs_to :project
  belongs_to :convention
end
