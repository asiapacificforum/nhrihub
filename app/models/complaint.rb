class Complaint < ActiveRecord::Base
  has_many :complaint_complaint_bases, :dependent => :destroy
  has_many :good_governance_complaint_bases, :through => :complaint_complaint_bases
  has_many :siu_complaint_bases, :through => :complaint_complaint_bases
  has_many :hr_complaint_bases, :class_name => 'Convention', :through => :complaint_complaint_bases
  has_many :complaint_conventions, :dependent => :destroy
  has_many :conventions, :through => :complaint_conventions

  alias_method :convention_complaint_bases, :conventions
end
