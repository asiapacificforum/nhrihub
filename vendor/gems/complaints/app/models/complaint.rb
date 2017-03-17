class Complaint < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_many :complaint_good_governance_complaint_bases, :dependent => :destroy
  has_many :complaint_special_investigations_unit_complaint_bases, :dependent => :destroy
  has_many :complaint_human_rights_complaint_bases, :dependent => :destroy
  has_many :good_governance_complaint_bases, :class_name => 'GoodGovernance::ComplaintBasis', :through => :complaint_good_governance_complaint_bases
  has_many :special_investigations_unit_complaint_bases, :class_name => 'Siu::ComplaintBasis', :through => :complaint_special_investigations_unit_complaint_bases
  has_many :human_rights_complaint_bases, :class_name => 'Convention', :through => :complaint_human_rights_complaint_bases
  has_many :corporate_services_complaint_bases, :class_name => 'CorporateServices::ComplaintBasis', :through => :complaint_corporate_servies_complaint_bases
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :assignees, :through => :assigns
  belongs_to :opened_by, :class_name => 'User', :foreign_key => :opened_by_id
  belongs_to :mandate # == area
  has_many :status_changes, :dependent => :destroy
  accepts_nested_attributes_for :status_changes
  has_many :complaint_statuses, :through => :status_changes
  #accepts_nested_attributes_for :complaint_statuses
  has_many :complaint_agencies, :dependent => :destroy
  has_many :agencies, :through => :complaint_agencies
  has_many :complaint_documents, :dependent => :destroy
  accepts_nested_attributes_for :complaint_documents
  has_many :communications, :dependent => :destroy

  attr_accessor :witness_name

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
    # workaround hack b/c FormData object sends "null" string for null values
    string_or_text_columns = Complaint.columns.select{|c| (c.type == :string) || (c.type == :text)}.map(&:name)
    string_or_text_columns.each do |column_name|
      complaint.send("#{column_name}=", nil) if complaint.send(column_name) == "null"
    end
    complaint.gender = nil if complaint.gender == 'undefined'
    integer_columns = Complaint.columns.select{|c| c.type == :integer}.map(&:name)
    # it's a hack... TODO there must be a better way!
    integer_columns.each do |column_name|
      complaint.send("#{column_name}=",nil) if complaint.send(column_name).nil? || complaint.send(column_name).zero?
    end
  end

  before_create do |complaint|
    if complaint.date_received.nil?
      complaint.date_received = DateTime.now
    end
  end

  def <=>(other)
    case_reference <=> other.case_reference
  end

  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assigns,
                        :current_assignee_id,
                        :new_assignee_id,
                        :current_assignee_name, :date,
                        :current_status_humanized, :attached_documents,
                        :mandate_name, :good_governance_complaint_basis_ids,
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

  def _complained_to_subject_agency
    complained_to_subject_agency ? 'yes' : 'no'
  end

  def agency_names
    list = agencies.map(&:description)
    def list.to_s
      self.map{|item| "<w:p><w:t>#{ERB::Util.html_escape(item)}</w:t></w:p>"}.join()
    end
    list
  end

  def date
    date_received.to_datetime.to_s unless date_received.nil?
  end

  def report_date
    date_received.to_date.to_s
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

  def index_url
    complaints_path('en', "html", {:case_reference => case_reference})
  end

  def complainant_full_name
    [firstName, lastName].join(' ')
  end

  def gender
    val = read_attribute(:gender)
    def val.to_s
      case self
      when "M"
        "male"
      when "F"
        "female"
      when "O"
        "other"
      else
        ""
      end
    end
    val
  end
end
