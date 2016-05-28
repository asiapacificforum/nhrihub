class Complaint < ActiveRecord::Base
  has_many :complaint_complaint_bases, :dependent => :destroy
  has_many :good_governance_complaint_bases, :class_name => 'GoodGovernance::ComplaintBasis', :through => :complaint_complaint_bases
  has_many :siu_complaint_bases, :class_name => 'Siu::ComplaintBasis', :through => :complaint_complaint_bases
  has_many :human_rights_complaint_bases, :class_name => 'Convention', :through => :complaint_complaint_bases
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :assignees, :through => :assigns
  belongs_to :opened_by, :class_name => 'User', :foreign_key => :opened_by_id
  belongs_to :closed_by, :class_name => 'User', :foreign_key => :closed_by_id
  has_many :complaint_documents
  has_many :complaint_complaint_categories, :dependent => :destroy
  has_many :complaint_categories, :through => :complaint_complaint_categories
  has_many :complaint_mandates, :dependent => :destroy
  has_many :mandates, :through => :complaint_mandates

  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assigns,
                        :current_assignee_name, :formatted_date,
                        :status_humanized, :complaint_documents,
                        :complaint_categories, :mandate_ids,
                        :good_governance_complaint_basis_ids,
                        :special_investigations_unit_complaint_basis_ids,
                        :human_rights_complaint_basis_ids])
  end

  def self.next_case_reference
    case_references = CaseReferenceCollection.new(all.pluck(:case_reference))
    case_references.next_ref
  end

  def formatted_date
    created_at.localtime.to_date.to_s(:short)
  end

  def current_assignee_name
    current_assignee.first_last_name if current_assignee
  end

  def current_assignee
    # first, b/c default sort is most-recent-first
    assigns.first.assignee unless assigns.empty?
  end

  def status_humanized
    I18n.t(".activerecord.values.complaint.status.#{status}")
  end

end
