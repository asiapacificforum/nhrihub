class Complaint < ActiveRecord::Base
  has_many :complaint_complaint_bases, :dependent => :destroy
  has_many :good_governance_complaint_bases, :class_name => 'GoodGovernance::ComplaintBasis', :through => :complaint_complaint_bases
  has_many :siu_complaint_bases, :class_name => 'Siu::ComplaintBasis', :through => :complaint_complaint_bases
  has_many :human_rights_complaint_bases, :class_name => 'Convention', :through => :complaint_complaint_bases
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :assignees, :through => :assigns, :source => :user

  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assignees, :current_assignee_name, :formatted_date, :status_humanized])
  end

  def formatted_date
    created_at.localtime.to_date.to_s(:short)
  end

  def current_assignee_name
    current_assignee.first_last_name if current_assignee
  end

  def current_assignee
    assigns.last.user unless assigns.empty?
  end

  def status_humanized
    I18n.t(".activerecord.values.complaint.status.#{status}")
  end

end
