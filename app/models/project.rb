class Project < ActiveRecord::Base
  has_many :project_performance_indicators, :dependent => :destroy
  has_many :performance_indicators, :through => :project_performance_indicators
  has_many :project_conventions, :dependent => :destroy
  has_many :conventions, :through => :project_conventions
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :project_mandates, :dependent => :destroy
  has_many :mandates, :through => :project_mandates
  has_many :project_types, :dependent => :destroy
  has_many :types, :through => :project_types
  has_many :project_agencies, :dependent => :destroy
  has_many :agencies, :through => :project_agencies
end
