class Agency < ActiveRecord::Base
  has_many :project_agencies, :dependent => :destroy
  has_many :agencies, :through => :project_agencies
end
