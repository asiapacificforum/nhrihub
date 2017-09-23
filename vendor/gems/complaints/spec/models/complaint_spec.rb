require 'rails_helper'

describe "complaint" do
  context "create" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
    end
    it "should create a status_change and link to 'Under Evaluation' complaint status" do
      expect(@complaint.status_changes.length).to eq 1
      expect(@complaint.complaint_statuses.length).to eq 1
      expect(@complaint.complaint_statuses.first.name).to eq "Under Evaluation"
      expect(@complaint.current_status_humanized).to eq "Under Evaluation"
    end
  end

  context "update status" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 2
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation", "Active"]
    end
  end

  context "update Complaint with no status change" do
    before do
      @complaint = Complaint.create({:status_changes_attributes => [{:name => nil}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
      @complaint.update({:status_changes_attributes => [{:name => "Active"}]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 2
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation", "Active"]
    end
  end
end

# just confirming here that the unusual associations work as expected
describe "Complaint with siu complaint basis" do
  before do
    @complaint = Complaint.create
    @siu_complaint_basis = Siu::ComplaintBasis.create(:name => "A thing")
    @complaint.special_investigations_unit_complaint_bases << @siu_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.special_investigations_unit_complaint_bases.count).to eq 1
    expect(@complaint.special_investigations_unit_complaint_bases.first.name).to eq "A thing"
    expect(Siu::ComplaintBasis.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
    expect(@complaint.special_investigations_unit_complaint_bases.first.type).to eq "Siu::ComplaintBasis"
  end
end

describe "Complaint with gg complaint basis" do
  before do
    @complaint = Complaint.create
    @good_governance_complaint_basis = GoodGovernance::ComplaintBasis.create(:name => "A thing")
    @complaint.good_governance_complaint_bases << @good_governance_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.good_governance_complaint_bases.count).to eq 1
    expect(@complaint.good_governance_complaint_bases.first.name).to eq "A thing"
    expect(GoodGovernance::ComplaintBasis.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
    expect(@complaint.good_governance_complaint_bases.first.type).to eq "GoodGovernance::ComplaintBasis"
  end
end

describe "Complaint with hr complaint basis" do
  before do
    @complaint = Complaint.create
    @human_rights_complaint_basis = Nhri::ComplaintBasis.create(:name => "A thing")
    @complaint.human_rights_complaint_bases << @human_rights_complaint_basis
    @complaint.save
  end

  it "should be saved with the associations" do
    expect(@complaint.human_rights_complaint_bases.count).to eq 1
    expect(@complaint.human_rights_complaint_bases.first.name).to eq "A thing"
    expect(Nhri::ComplaintBasis.count).to eq 1
    expect(Convention.count).to eq 1
    expect(ComplaintComplaintBasis.count).to eq 1
  end
end

describe "next case reference" do
  let(:current_year){ Date.today.strftime('%y') }
  let(:this_year_case_reference) { "C"+current_year+"-22" }
  context "existing Complaints are from previous year" do
    before do
      Complaint.create(:case_reference => 'C12-35')
    end

    it "should start the sequence at 1 with the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }-1")
    end
  end

  context "existing Complaints are from the current year" do
    before do
      Complaint.create(:case_reference => this_year_case_reference)
    end
    it "should increment the sequence only" do
      expect(Complaint.next_case_reference).to eq("C#{current_year}-23")
    end
  end

  context "no existing complaints" do
    before do
      # nothing!
    end

    it "should create the first case reference for the current year" do
      expect(Complaint.next_case_reference).to eq("C#{ current_year }-1")
    end
  end
end

describe "sort algorithm" do
  before do
    Complaint.create(:case_reference => "C17-4")
    Complaint.create(:case_reference => "C16-10")
    Complaint.create(:case_reference => "C16-2")
    Complaint.create(:case_reference => "C16-1")
    Complaint.create(:case_reference => "C16-5")
    Complaint.create(:case_reference => "C15-11")
  end

  it "should sort by ascending case reference" do
    expect(Complaint.all.sort.pluck(:case_reference)).to eq ["C15-11","C16-1","C16-2","C16-5","C16-10","C17-4"]
  end
end

describe "#index_url" do
  before do
    @complaint = Complaint.create(:case_reference => 'C12-35')
  end

  it "should contain protocol, host, locale, complaints path, and case_reference query string" do
    route = Rails.application.routes.recognize_path(@complaint.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@complaint.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/complaints"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "case_reference"
    expect(params.values.first).to eq ["C12-35"]
  end
end

# verify that this survives performance improvements
describe "#as_json" do
  context "with a full complement of associations" do
    before do
      agencies = AGENCIES.each do |short,full|
        Agency.create(:name => short, :full_name => full)
      end

      ["GoodGovernance", "Nhri", "Siu"].each do |type_prefix|
        klass = type_prefix+"::ComplaintBasis"
        klass.constantize::DefaultNames.each do |name|
          if klass.constantize.send(:where, "\"#{klass.constantize.table_name}\".\"name\"='#{name}'").length > 0
            complaint_basis = klass.constantize.send(:where, "\"#{klass.constantize.table_name}\".\"name\"='#{name}'").first
          else
            klass.constantize.create(:name => name)
          end
        end
      end

      ["Open", "Suspended", "Closed"].each do |name|
        ComplaintStatus.create(:name => name)
      end

      4.times do
        FactoryGirl.create(:user, :with_password)
      end

      2.times do |i|
        FactoryGirl.create(:complaint, :with_fixed_associations, :with_assignees, :with_document, :with_comm, :with_reminders, :with_two_notes, :case_reference => "C17-#{3-i}")
      end
    end

    it 'should create a properly formatted json object' do
      @complaints = JSON.parse(Complaint.all.to_json)
      expect(@complaints).to be_an Array
      expect(@complaints.length).to be 2
      expect(@complaints.first.keys).to match_array ["id", "case_reference", "village", "phone", "created_at", "updated_at", "desired_outcome", "complained_to_subject_agency", "date_received", "imported", "mandate_id", "mandate_ids", "email", "gender", "dob", "details", "firstName", "lastName", "chiefly_title", "occupation", "employer", "reminders", "notes", "assigns", "current_assignee_id", "current_assignee_name", "date", "date_of_birth", "current_status_humanized", "attached_documents", "good_governance_complaint_basis_ids", "special_investigations_unit_complaint_basis_ids", "human_rights_complaint_basis_ids", "status_changes", "agency_ids", "communications"]
      expect(@complaints.first["id"]).to eq Complaint.first.id
      expect(@complaints.first["case_reference"]).to eq Complaint.first.case_reference
      expect(@complaints.first["village"]).to eq Complaint.first.village
      expect(@complaints.first["phone"]).to eq Complaint.first.phone
      expect(DateTime.parse @complaints.first["created_at"]).to eq Complaint.first.created_at.to_datetime
      expect(DateTime.parse @complaints.first["updated_at"]).to eq Complaint.first.updated_at.to_datetime
      expect(@complaints.first["desired_outcome"]).to eq Complaint.first.desired_outcome
      expect(@complaints.first["complained_to_subject_agency"]).to eq Complaint.first.complained_to_subject_agency
      expect(@complaints.first["date_received"]).to eq Complaint.first.date_received
      expect(@complaints.first["imported"]).to eq Complaint.first.imported
      expect(@complaints.first["mandate_id"]).to eq Complaint.first.mandate_id
      expect(@complaints.first["email"]).to eq Complaint.first.email
      expect(@complaints.first["gender"]).to eq Complaint.first.gender
      expect(@complaints.first["dob"]).to eq Complaint.first.dob
      expect(@complaints.first["details"]).to eq Complaint.first.details
      expect(@complaints.first["firstName"]).to eq Complaint.first.firstName
      expect(@complaints.first["lastName"]).to eq Complaint.first.lastName
      expect(@complaints.first["chiefly_title"]).to eq Complaint.first.chiefly_title
      expect(@complaints.first["occupation"]).to eq Complaint.first.occupation
      expect(@complaints.first["employer"]).to eq Complaint.first.employer
      expect(@complaints.first["current_assignee_id"]).to eq Complaint.first.current_assignee_id
      expect(@complaints.first["current_assignee_name"]).to eq Complaint.first.current_assignee_name
      expect(@complaints.first["date"]).to eq Complaint.first.date
      expect(@complaints.first["date_of_birth"]).to eq Complaint.first.date_of_birth
      expect(@complaints.first["current_status_humanized"]).to eq Complaint.first.current_status_humanized
      expect(@complaints.first["reminders"].first.keys).to match_array ["id", "text", "reminder_type", "remindable_id", "remindable_type", "start_date", "next", "user_id", "recipient", "next_date", "previous_date", "url", "start_year", "start_month", "start_day"]
      expect(@complaints.first["reminders"].first["recipient"].keys).to match_array ["id", "first_last_name"]
      expect(@complaints.first["notes"].first.keys).to match_array ["author_id", "author_name", "created_at", "date", "editor_id", "editor_name", "id", "notable_id", "notable_type", "text", "updated_at", "updated_on", "url"]
      expect(@complaints.first["notes"].first["author_name"]).to eq Complaint.first.notes.first.author_name
      expect(@complaints.first["notes"].first["editor_name"]).to eq Complaint.first.notes.first.editor_name
      expect(@complaints.first["notes"].first["url"]).to eq Rails.application.routes.url_helpers.complaint_note_path(:en,1,1)
      expect(@complaints.first["notes"].first["updated_on"]).to eq Complaint.first.notes.first.updated_on
      expect(@complaints.first["notes"].first["date"]).to eq Complaint.first.notes.first.date
      expect(@complaints.first["assigns"].first.keys).to match_array ["date", "name"]
      expect(@complaints.first["assigns"].first["date"]).to eq Complaint.first.assigns.first.date
      expect(@complaints.first["assigns"].first["name"]).to eq Complaint.first.assigns.first.name
      expect(@complaints.first["attached_documents"].first.keys).to match_array ["complaint_id", "file_id", "filename", "filesize", "id", "lastModifiedDate", "original_type", "serialization_key", "title", "url", "user_id"]
      expect(@complaints.first["attached_documents"].first["url"]).to eq Complaint.first.attached_documents.first.url
      expect(@complaints.first["good_governance_complaint_basis_ids"]).to be_an Array
      expect(@complaints.first["good_governance_complaint_basis_ids"]).to match_array Complaint.first.good_governance_complaint_basis_ids
      expect(@complaints.first["special_investigations_unit_complaint_basis_ids"]).to be_an Array
      expect(@complaints.first["human_rights_complaint_basis_ids"]).to be_an Array
      expect(@complaints.first["current_assignee_id"]).to eq Complaint.first.current_assignee_id
      expect(@complaints.first["status_changes"].first.keys).to match_array ["date", "status_humanized", "user_name"]
      expect(@complaints.first["status_changes"].first["date"]).to eq Complaint.first.status_changes.first.date
      expect(@complaints.first["status_changes"].first["status_humanized"]).to eq Complaint.first.status_changes.first.status_humanized
      expect(@complaints.first["status_changes"].first["user_name"]).to eq Complaint.first.status_changes.first.user_name
      expect(@complaints.first["agency_ids"]).to be_an Array
      expect(@complaints.first["communications"].first.keys).to match_array ["attached_documents", "communicants", "complaint_id", "date", "direction", "id", "mode", "note", "user", "user_id"]
      expect(@complaints.first["communications"].first["attached_documents"].first.keys ).to match_array ["communication_id", "file_id", "filename", "filesize", "id", "lastModifiedDate", "original_type", "title", "user_id"]
      expect(@complaints.first["communications"].first["communicants"].first.keys).to match_array ["address", "email", "id", "name", "organization_id", "phone", "title_key"]
    end
  end

  context "with empty associations" do
    before do
      2.times do |i|
        FactoryGirl.create(:complaint, :case_reference => "C17-#{3-i}")
      end
    end

    it 'should create a properly formatted json object' do
      @complaints = JSON.parse(Complaint.all.to_json)
      expect(@complaints).to be_an Array
      expect(@complaints.length).to be 2
      expect(@complaints.first.keys).to match_array ["id", "case_reference", "village", "phone", "created_at", "updated_at", "desired_outcome", "complained_to_subject_agency", "date_received", "imported", "mandate_id", "mandate_ids", "email", "gender", "dob", "details", "firstName", "lastName", "chiefly_title", "occupation", "employer", "reminders", "notes", "assigns", "current_assignee_id", "current_assignee_name", "date", "date_of_birth", "current_status_humanized", "attached_documents", "good_governance_complaint_basis_ids", "special_investigations_unit_complaint_basis_ids", "human_rights_complaint_basis_ids", "status_changes", "agency_ids", "communications"]
      expect(@complaints.first["reminders"]).to be_empty
      expect(@complaints.first["notes"]).to be_empty
      expect(@complaints.first["assigns"]).to be_empty
      expect(@complaints.first["attached_documents"]).to be_empty
      expect(@complaints.first["good_governance_complaint_basis_ids"]).to be_empty
      expect(@complaints.first["special_investigations_unit_complaint_basis_ids"]).to be_empty
      expect(@complaints.first["human_rights_complaint_basis_ids"]).to be_empty
      expect(@complaints.first["status_changes"]).to be_empty
      expect(@complaints.first["agency_ids"]).to be_empty
      expect(@complaints.first["communications"]).to be_empty
    end
  end
end
