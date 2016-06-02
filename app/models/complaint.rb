class Complaint < ActiveRecord::Base
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
  belongs_to :closed_by, :class_name => 'User', :foreign_key => :closed_by_id
  has_many :complaint_documents
  has_many :complaint_complaint_categories, :dependent => :destroy
  has_many :complaint_categories, :through => :complaint_complaint_categories
  has_many :complaint_mandates, :dependent => :destroy
  has_many :mandates, :through => :complaint_mandates
  has_many :status_changes

  def status_changes_attributes=(attrs)
    attrs.each do |attr|
      status_unchanged = !status_changes.empty? &&( (current_status && attr[:status_humanized] == "open" ) || (current_status && attr[:new_value] == "closed" ))
      status_has_changed = !status_unchanged
      if status_changes.empty? || status_has_changed
        status_changes.build(attr)
      end
    end
    #this passes the model specs, but integrations specs are failing is it because of this: ?
    #attrs.each do |attr|
      #if status_changes.empty? || !(current_status && attr[:status_humanized] == "open"  )
        #status_changes.build(attr)
      #end
    #end
  end


  def as_json(options = {})
    super( :methods => [:reminders, :notes, :assigns,
                        :current_assignee_name, :formatted_date,
                        :current_status_humanized, :complaint_documents,
                        :complaint_categories, :mandate_ids,
                        :good_governance_complaint_basis_ids,
                        :special_investigations_unit_complaint_basis_ids,
                        :human_rights_complaint_basis_ids, :status_changes])
  end

  def self.next_case_reference
    case_references = CaseReferenceCollection.new(all.pluck(:case_reference))
    case_references.next_ref
  end

  #def closed_by_name
    #closed_by.first_last_name if closed? && closed_by
  #end

  #def closed_on_date
    #closed_on.localtime.to_date.to_s(:short) if closed?
  #end

  def closed?
    !current_status
  end

  def current_status
    status_changes.last.new_value
  end

  def current_status_humanized
    status_changes.last.status_humanized
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

  def current_assignee_id=(id)
    self.assignees << User.find(id) if id
  end

end
