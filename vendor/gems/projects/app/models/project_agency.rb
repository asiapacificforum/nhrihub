class ProjectAgency < ActiveRecord::Base
  belongs_to :project
  belongs_to :agency
end
