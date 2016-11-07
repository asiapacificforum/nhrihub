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
  #has_many :complaint_mandates, :dependent => :destroy
  belongs_to :mandate #, :through => :complaint_mandates
  has_many :status_changes, :dependent => :destroy
  accepts_nested_attributes_for :status_changes
  has_many :complaint_statuses, :through => :status_changes
  #accepts_nested_attributes_for :complaint_statuses
  has_many :complaint_agencies, :dependent => :destroy
  has_many :agencies, :through => :complaint_agencies
  has_many :complaint_documents, :dependent => :destroy
  accepts_nested_attributes_for :complaint_documents
  has_many :communications, :dependent => :destroy

  def status_changes_attributes=(attrs)
    # only create a status_change object if this is a new complaint
    # or if the status is changing
    attrs = attrs[0]
    attrs.symbolize_keys
    change_date = attrs[:change_date].nil? ? DateTime.now : DateTime.new(attrs[:change_date])
    user_id = attrs[:user_id]
    if !persisted?
      complaint_status = ComplaintStatus.find_or_create_by(:name => "Under Evaluation")
      complaint_status_id = complaint_status.id
      status_changes.build({:user_id => user_id,
                            :change_date => change_date,
                            :complaint_status_id => complaint_status_id})
    elsif !(attrs[:name].nil? || attrs[:name] == "null") && attrs[:name] != current_status_humanized
      complaint_status = ComplaintStatus.find_or_create_by(:name => attrs[:name])
      complaint_status_id = complaint_status.id
      status_changes.build({:user_id => user_id,
                            :change_date => change_date,
                            :complaint_status_id => complaint_status_id})
    end
  end

  before_save do |complaint|
    string_columns = Complaint.columns.select{|c| c.type == :string}.map(&:name)
    string_columns.each do |column_name|
      complaint.send("#{column_name}=", nil) if complaint.send(column_name) == "null"
    end
    complaint.gender = nil if complaint.gender == 'undefined'
  end

  before_create do |complaint|
    if complaint.date_received.nil?
      complaint.date_received = DateTime.now
    end
  end

  def complained_to_subject_agency
    val = read_attribute(:complained_to_subject_agency)
    val ? "Y" : "N"
  end

  #def complained_to_subject_agency=(val)
    #persisted_val = val=="Y" ? true : false
    #write_attribute(:complained_to_subject_agency, persisted_val)
  #end

  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assigns,
                        :current_assignee_id,
                        :new_assignee_id,
                        :current_assignee_name, :date,
                        :current_status_humanized, :attached_documents,
                        :complaint_categories, :mandate_name,
                        :good_governance_complaint_basis_ids,
                        :special_investigations_unit_complaint_basis_ids,
                        :human_rights_complaint_basis_ids, :status_changes,
                        :agency_ids,
                        :communications])
  end

  def mandate_name
    mandate && mandate.name
  end

  def mandate_name=(name)
    self.mandate_id = Mandate.where(:key => name.gsub(/\s/,'').underscore).first.id
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
    date_received.to_datetime.to_s unless date_received.nil?
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
