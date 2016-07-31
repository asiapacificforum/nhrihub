class ProjectMandate < ActiveRecord::Base
  belongs_to :project
  belongs_to :mandate
end
