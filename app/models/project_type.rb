class ProjectType < ActiveRecord::Base
  has_many :project_project_types, :dependent => :destroy
  has_many :projects, :through => :project_project_types
  belongs_to :mandate

  def as_json(options={})
    super(:only => [:name, :id])
  end
end
