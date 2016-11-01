class Complaint < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_many :complaint_good_governance_complaint_bases, :dependent => :destroy
  has_many :complaint_special_investigations_unit_complaint_bases, :dependent => :destroy
  has_many :complaint_human_rights_complaint_bases, :dependent => :destroy
  has_many :good_governance_complaint_bases, :class_name => 'GoodGovernance::ComplaintBasis', :through => :complaint_good_governance_complaint_bases
  has_many :special_investigations_unit_complaint_bases, :class_name => 'Siu::ComplaintBasis', :through => :complaint_special_investigations_unit_complaint_bases
  has_many :human_rights_complaint_bases, :class_name => 'Convention', :through => :complaint_human_rights_complaint_bases
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :assignees, :through => :assigns
  belongs_to :opened_by, :class_name => 'User', :foreign_key => :opened_by_id
  has_many :complaint_complaint_categories, :dependent => :destroy
  has_many :complaint_categories, :through => :complaint_complaint_categories
  has_many :complaint_mandates, :dependent => :destroy
  has_many :mandates, :through => :complaint_mandates
  has_many :status_changes, :dependent => :destroy
  has_many :complaint_statuses, :through => :status_changes
  has_many :complaint_agencies, :dependent => :destroy
  has_many :agencies, :through => :complaint_agencies
  has_many :complaint_documents, :dependent => :destroy
  accepts_nested_attributes_for :complaint_documents
  has_many :communications, :dependent => :destroy

  def status_changes_attributes=(attrs)
    # only create a status_change object if this is a new complaint
    # or if the status is changing
    attrs.each do |attr|
      if status_changes.empty? || !(current_status && attr[:status_humanized] == "open"  )
        status_changes.build(attr)
      end
    end
  end


  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assigns,
                        :current_assignee_id,
                        :new_assignee_id,
                        :current_assignee_name, :date,
                        :current_status_humanized, :attached_documents,
                        :complaint_categories, :mandate_ids,
                        :good_governance_complaint_basis_ids,
                        :special_investigations_unit_complaint_basis_ids,
                        :human_rights_complaint_basis_ids, :status_changes,
                        :agency_ids,
                        :communications])
  end

  def attached_documents
    complaint_documents
  end

  def new_assignee_id
    nil
  end

  def self.next_case_reference
    case_references = CaseReferenceCollection.new(all.pluck(:case_reference))
    case_references.next_ref
  end

  def closed?
    !current_status
  end

  def current_status
    status_changes.last.complaint_status.name
  end

  def current_status_humanized
    status_changes.last.status_humanized unless status_changes.empty?
  end

  def date
    created_at.to_datetime.to_s
  end

  def current_assignee_name
    current_assignee.first_last_name if current_assignee
  end

  def current_assignee
    # first, b/c default sort is most-recent-first
    assigns.first.assignee unless assigns.empty?
  end

  def new_assignee_id=(id)
    unless id.blank? || id=="null"
      self.assignees << User.find(id)
    end
  end

  def current_assignee_id
    current_assignee.id if current_assignee
  end

  def notable_url(notable_id)
    complaint_note_path('en',id,notable_id)
  end

  def remindable_url(remindable_id)
    complaint_reminder_path('en',id,remindable_id)
  end
end
