class Type < ActiveRecord::Base
  has_many :project_types, :dependent => :destroy
  has_many :types, :through => :project_types
end
