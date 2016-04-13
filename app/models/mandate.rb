class Mandate < ActiveRecord::Base
  has_many :project_mandates, :dependent => :destroy
  has_many :projects, :through => :project_mandates
end
