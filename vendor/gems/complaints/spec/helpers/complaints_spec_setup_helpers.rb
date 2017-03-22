require 'rspec/core/shared_context'

module ComplaintsSpecSetupHelpers
  extend RSpec::Core::SharedContext

  def populate_database
    create_mandates
    create_agencies
    create_staff
    create_complaint_statuses
    FactoryGirl.create(:complaint, :case_reference => "c12-34",
                       :date_received => DateTime.now,
                       :village => Faker::Address.city,
                       :phone => Faker::PhoneNumber.phone_number,
                       :dob => Date.new(1950,8,19),
                       :human_rights_complaint_bases => hr_complaint_bases,
                       :good_governance_complaint_bases => gg_complaint_bases,
                       :special_investigations_unit_complaint_bases => siu_complaint_bases,
                       :assigns => assigns,
                       :desired_outcome => Faker::Lorem.sentence,
                       :details => Faker::Lorem.sentence,
                       :complaint_documents => complaint_docs,
                       :status_changes => _status_changes,
                       :mandate_ids => [_mandate_id],
                       :agencies => _agencies,
                       :communications => _communications)
    set_file_defaults
  end

  def create_complaints
    FactoryGirl.create(:complaint, :case_reference => "c12-22")
    FactoryGirl.create(:complaint, :case_reference => "c12-33")
    @complaint = FactoryGirl.create(:complaint, :case_reference => "c12-55")
  end

  private
  def set_file_defaults
    SiteConfig["complaint_document.filetypes"]=["pdf"]
    SiteConfig["complaint_document.filesize"]= 5
    SiteConfig["communication_document.filetypes"]=["pdf"]
    SiteConfig["communication_document.filesize"]= 5
  end

  def create_staff
    FactoryGirl.create(:user, :staff, :with_password, :firstName => "Hailee", :lastName => "Ortiz")
  end

  def create_mandates
    [:good_governance, :human_rights, :special_investigations_unit, :corporate_services].each do |key|
      FactoryGirl.create(:mandate, :key => key)
    end
  end

  def create_complaint_statuses
     ["Open", "Incomplete", "Closed"].each do |status_name|
       FactoryGirl.create(:complaint_status, :name => status_name)
     end
  end

  def _communications
    [ FactoryGirl.create(:communication) ]
  end

  def _mandate_id
    Mandate.find_by(:key => 'human_rights' ).id
  end

  def _agencies
    [ Agency.find_by(:name => 'SAA') ]
  end

  def _status_changes
    # open 100 days ago, closed 50 days ago
    [FactoryGirl.build(:status_change,
                       :created_at => DateTime.now.advance(:days => -100),
                       :complaint_status_id => FactoryGirl.create(:complaint_status, :name => "Open").id,
                       :change_date => DateTime.now.advance(:days => -100),
                       :user_id => User.staff.pluck(:id).first),
     FactoryGirl.build(:status_change,
                       :created_at => DateTime.now.advance(:days => -50),
                       :complaint_status_id => FactoryGirl.create(:complaint_status, :name => "Closed").id,
                       :change_date => DateTime.now.advance(:days => -50),
                       :user_id => User.staff.pluck(:id).second )]
  end

  def complaint_docs
    Array.new(2) { FactoryGirl.create(:complaint_document) }
  end

  def hr_complaint_bases
    names = ["CAT", "ICESCR"]
    names.collect{|name| FactoryGirl.create(:convention, :name => name)}
  end

  def gg_complaint_bases
    names = ["Delayed action", "Failure to act", "Contrary to Law", "Oppressive", "Private"]
    names.collect{|name| FactoryGirl.create(:good_governance_complaint_basis, :name => name) }
    names = ["Delayed action", "Failure to act"]
    GoodGovernance::ComplaintBasis.where(:name => names)
  end

  def siu_complaint_bases
    names = ["Unreasonable delay", "Not properly investigated"]
    names.collect{|name| FactoryGirl.create(:siu_complaint_basis, :name => name) }
  end

  def assigns
    Array.new(2) do
      assignee = FactoryGirl.create(:assignee, :with_password)
      date = DateTime.now.advance(:days => -rand(365))
      Assign.new(:created_at => date, :assignee => assignee)
    end
  end

  def create_agencies
    AGENCIES.each do |name,full_name|
      Agency.create(:name => name, :full_name => full_name)
    end
  end
end
