class Agency < ActiveRecord::Base
  has_many :project_agencies, :dependent => :destroy
  has_many :agencies, :through => :project_agencies
  def as_json(options={})
    super(:except => [:created_at, :updated_at])
  end
end
