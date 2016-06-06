class Agency < ActiveRecord::Base
  has_many :project_agencies, :dependent => :destroy
  has_many :projects, :through => :project_agencies
  has_many :complaint_agencies, :dependent => :destroy
  has_many :complaints, :through => :complaint_agencies
  def as_json(options={})
    super(:except => [:created_at, :updated_at])
  end
end
