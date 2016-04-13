class Convention < ActiveRecord::Base
  has_many :project_conventions, :dependent => :destroy
  has_many :conventions, :through => :project_conventions
end
