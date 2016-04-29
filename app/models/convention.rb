class Convention < ActiveRecord::Base
  has_many :project_conventions, :dependent => :destroy
  has_many :conventions, :through => :project_conventions
  def as_json(options={})
    super(:except => [:created_at, :updated_at])
  end
end
