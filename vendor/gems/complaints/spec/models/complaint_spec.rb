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
  before do
    4.times do
      FactoryGirl.create(:user, :with_password)
    end

    2.times do |i|
      FactoryGirl.create(:complaint, :with_associations, :with_assignees, :with_document, :with_comm, :with_reminders, :with_notes, :case_reference => "C17-#{3-i}")
    end
    @complaints = JSON.parse(Complaint.all.to_json)
  end

  it 'should create a properly formatted json object' do
    expect(@complaints).to be_an Array
    expect(@complaints.length).to be 2
    #expect(@complaints.first.keys).to match_array(['id', 'case_reference'])
  end
end
# [{"id"=>173, "case_reference"=>"C17-3", "village"=>"East Jeromy", "phone"=>"634-059-6483 x06012", "created_at"=>"2015-12-12T14:28:29.058Z", "updated_at"=>"2017-09-11T14:28:29.094Z", "desired_outcome"=>nil, "complained_to_subject_agency"=>nil, "date_received"=>"2017-09-11", "imported"=>false, "mandate_id"=>nil, "email"=>nil, "gender"=>nil, "dob"=>nil, "details"=>"Et dolorum similique itaque voluptas. At ea neque eligendi maxime. Eos hic et suscipit. Voluptas quae quos similique odio ut voluptate. Dolorum exercitationem nam reprehenderit. Sunt repellat architecto at. Eveniet pariatur odit quia labore quam porro nostrum. Vel fuga quasi natus consequatur sit eum vel. Et ea dolor est fuga.", "firstName"=>"Christine", "lastName"=>"Boehm", "chiefly_title"=>"Prosacco", "occupation"=>"teacher", "employer"=>"Koepp, Prosacco and Marvin", "reminders"=>[{"id"=>4066, "text"=>"Non et consequatur. Qui dolores dolorem commodi.", "reminder_type"=>"weekly", "remindable_id"=>173, "remindable_type"=>"Complaint", "start_date"=>"2018-02-05T00:00:00.000Z", "next"=>"2018-02-05T00:00:00.000Z", "user_id"=>13, "recipient"=>{"id"=>13, "first_last_name"=>"August Franecki"}, "next_date"=>"Feb 5, 2018", "previous_date"=>"none", "url"=>"/en/complaints/173/reminders/4066", "start_year"=>2018, "start_month"=>2, "start_day"=>5}], "notes"=>[], "assigns"=>[{"date"=>"Aug 3, 2017", "name"=>"Les Nightingill"}, {"date"=>"Jun 2, 2017", "name"=>"August Franecki"}], "current_assignee_id"=>23, "current_assignee_name"=>"Les Nightingill", "date"=>"Sep 11, 2017", "date_of_birth"=>nil, "current_status_humanized"=>"Open", "attached_documents"=>[{"id"=>158, "complaint_id"=>173, "file_id"=>"6d281bf40e962ec80de9e04489d61134b7c3e8f93635de9e4b68a6641fc9", "title"=>"Pacific System Prevention Educational Senior", "filesize"=>19555, "filename"=>"shared_disproportionate_poorindigenous.docx", "lastModifiedDate"=>"2016-09-23T00:00:00.000Z", "original_type"=>"application/pdf", "user_id"=>nil, "url"=>"/en/complaint_documents/158", "serialization_key"=>"complaint[complaint_documents_attributes][]"}], "mandate_ids"=>[], "good_governance_complaint_basis_ids"=>[1, 2], "special_investigations_unit_complaint_basis_ids"=>[9, 11], "human_rights_complaint_basis_ids"=>[3, 8], "status_changes"=>[{"user_name"=>"Jalen Collins", "date"=>"2017-09-11T14:28:29.855Z", "status_humanized"=>"Open"}], "agency_ids"=>[893, 900], "communications"=>[{"id"=>32, "complaint_id"=>173, "user_id"=>5, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:29.174Z", "note"=>nil, "user"=>{"id"=>5, "first_last_name"=>"Juana Breitenberg"}, "attached_documents"=>[{"id"=>26, "communication_id"=>32, "file_id"=>"3355f58df9bf23c261771ff0c9a72519d0c8ee6995ac1be2f0aeed803b50", "title"=>"et iste est in molestias architecto nemo consequuntur", "filesize"=>26278, "filename"=>"non_quibusdam.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>34, "name"=>"Miss Madelyn Stokes", "title_key"=>"Dr", "email"=>"shemar.carter@marquardt.net", "phone"=>"(644) 738-2092 x3622", "address"=>"2579 Gibson Forges", "organization_id"=>16}]}, {"id"=>31, "complaint_id"=>173, "user_id"=>11, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:29.097Z", "note"=>nil, "user"=>{"id"=>11, "first_last_name"=>"Michale Kessler"}, "attached_documents"=>[{"id"=>25, "communication_id"=>31, "file_id"=>"d56f3111f57503c9fdba632557cf1bee6a1506d9d139bfc1ccf2bec79277", "title"=>"eum temporibus quis distinctio dolorum et alias esse", "filesize"=>37394, "filename"=>"aut_ullam.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>33, "name"=>"Mr. Guy Johnston", "title_key"=>"Dr", "email"=>"bernardo@reicherthermiston.org", "phone"=>"(539) 009-0137", "address"=>"440 Hoppe Light", "organization_id"=>27}]}]},
#  {"id"=>174, "case_reference"=>"C17-2", "village"=>"New Rhianna", "phone"=>"1-143-598-6701", "created_at"=>"2015-09-27T14:28:29.882Z", "updated_at"=>"2017-09-11T14:28:29.887Z", "desired_outcome"=>nil, "complained_to_subject_agency"=>nil, "date_received"=>"2017-09-11", "imported"=>false, "mandate_id"=>nil, "email"=>nil, "gender"=>nil, "dob"=>nil, "details"=>"Repellendus a nulla ex quam aut doloremque. Quis aut nam sunt dolorem similique natus. Modi nesciunt nihil laborum itaque. Ea quas corrupti error ullam repudiandae aut. Officiis sed laboriosam aut. Velit et animi ad. Alias nam est qui excepturi.", "firstName"=>"Christian", "lastName"=>"Kirlin", "chiefly_title"=>"Lemke", "occupation"=>"biologist", "employer"=>"Mueller-Cummings", "reminders"=>[{"id"=>4067, "text"=>"Vel sint quia similique sapiente alias voluptatibus eum. Rerum ad modi delectus in voluptatem.", "reminder_type"=>"monthly", "remindable_id"=>174, "remindable_type"=>"Complaint", "start_date"=>"2018-06-04T00:00:00.000Z", "next"=>"2018-06-04T00:00:00.000Z", "user_id"=>11, "recipient"=>{"id"=>11, "first_last_name"=>"Michale Kessler"}, "next_date"=>"Jun 4, 2018", "previous_date"=>"none", "url"=>"/en/complaints/174/reminders/4067", "start_year"=>2018, "start_month"=>6, "start_day"=>4}], "notes"=>[{"id"=>1104, "text"=>"Quia molestias tenetur est numquam corrupti quia incidunt aut blanditiis.", "notable_id"=>174, "author_id"=>10, "editor_id"=>9, "created_at"=>"2017-09-11T14:28:29.986Z", "updated_at"=>"2017-09-11T14:28:29.986Z", "notable_type"=>"Complaint", "date"=>"Sep 11, 2017", "author_name"=>"Jalen Collins", "editor_name"=>"Alfreda Cummerata", "updated_on"=>"Sep 11, 2017", "url"=>"/en/complaints/174/notes/1104"}], "assigns"=>[{"date"=>"Mar 18, 2017", "name"=>"Abdiel Aufderhar"}, {"date"=>"Jan 3, 2017", "name"=>"Daren Auer"}], "current_assignee_id"=>8, "current_assignee_name"=>"Abdiel Aufderhar", "date"=>"Sep 11, 2017", "date_of_birth"=>nil, "current_status_humanized"=>"Open", "attached_documents"=>[{"id"=>159, "complaint_id"=>174, "file_id"=>"75b729b923536bbe8a0bb2d181aa20ee52809971950ec437354e2986bd08", "title"=>"Leaders This Advice Someone Dangerous Nhris Malaysia", "filesize"=>17688, "filename"=>"this_professional_avenueup_calendar.docx", "lastModifiedDate"=>"2017-07-31T00:00:00.000Z", "original_type"=>"application/pdf", "user_id"=>nil, "url"=>"/en/complaint_documents/159", "serialization_key"=>"complaint[complaint_documents_attributes][]"}], "mandate_ids"=>[], "good_governance_complaint_basis_ids"=>[1, 5], "special_investigations_unit_complaint_basis_ids"=>[9, 11], "human_rights_complaint_basis_ids"=>[1, 9], "status_changes"=>[{"user_name"=>"Daphne Will", "date"=>"2017-09-11T14:28:30.323Z", "status_humanized"=>"Open"}], "agency_ids"=>[881, 891], "communications"=>[{"id"=>34, "complaint_id"=>174, "user_id"=>24, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:29.934Z", "note"=>nil, "user"=>{"id"=>24, "first_last_name"=>"Ash Bowe"}, "attached_documents"=>[{"id"=>28, "communication_id"=>34, "file_id"=>"d94c9b7d8be2c5c1af60f87cfca1f3da94eaf349bff7e00b8aa635dc8c03", "title"=>"laborum adipisci nostrum ea cumque ea accusantium distinctio", "filesize"=>34559, "filename"=>"et_consequatur.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>36, "name"=>"Darby Collins", "title_key"=>"Dr", "email"=>"glenda@schaefer.io", "phone"=>"1-359-647-9776 x37264", "address"=>"68983 Devon Estates", "organization_id"=>7}]}, {"id"=>33, "complaint_id"=>174, "user_id"=>1, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:29.890Z", "note"=>nil, "user"=>{"id"=>1, "first_last_name"=>"Marcus Ratke"}, "attached_documents"=>[{"id"=>27, "communication_id"=>33, "file_id"=>"652031a3ae3354fdd740f9a736964cf3bf644a43e572d67d0b8fefa24aaf", "title"=>"fugiat est non ratione rem asperiores occaecati eaque", "filesize"=>13960, "filename"=>"ut_autem.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>35, "name"=>"Miss Ernestine Ferry", "title_key"=>"Dr", "email"=>"prince_waelchi@rogahn.info", "phone"=>"706-902-6422", "address"=>"144 Will Turnpike", "organization_id"=>16}]}]},
#  {"id"=>175, "case_reference"=>"C17-1", "village"=>"Port Priscillaville", "phone"=>"568.391.0637 x65990", "created_at"=>"2016-08-17T14:28:30.338Z", "updated_at"=>"2017-09-11T14:28:30.343Z", "desired_outcome"=>nil, "complained_to_subject_agency"=>nil, "date_received"=>"2017-09-11", "imported"=>false, "mandate_id"=>nil, "email"=>nil, "gender"=>nil, "dob"=>nil, "details"=>"Qui id et aut enim. Recusandae sequi ratione id deserunt quod amet. Earum quis esse. Maiores culpa consequuntur quia vel. Aliquid quas atque voluptatem architecto. Laudantium quidem magni facere veniam odit.", "firstName"=>"Zelma", "lastName"=>"Grimes", "chiefly_title"=>"Nicolas", "occupation"=>"musician", "employer"=>"Streich-Bruen", "reminders"=>[{"id"=>4068, "text"=>"Cum iusto corporis perspiciatis atque. Corporis dolorem est perferendis.", "reminder_type"=>"semi-annual", "remindable_id"=>175, "remindable_type"=>"Complaint", "start_date"=>"2018-02-18T00:00:00.000Z", "next"=>"2018-02-18T00:00:00.000Z", "user_id"=>14, "recipient"=>{"id"=>14, "first_last_name"=>"Khalil Rau"}, "next_date"=>"Feb 18, 2018", "previous_date"=>"Aug 18, 2017", "url"=>"/en/complaints/175/reminders/4068", "start_year"=>2018, "start_month"=>2, "start_day"=>18}], "notes"=>[{"id"=>1105, "text"=>"Vel inventore est amet consequatur repellat similique sit officia blanditiis voluptates dolorum placeat possimus.", "notable_id"=>175, "author_id"=>3, "editor_id"=>23, "created_at"=>"2017-09-11T14:28:30.438Z", "updated_at"=>"2017-09-11T14:28:30.438Z", "notable_type"=>"Complaint", "date"=>"Sep 11, 2017", "author_name"=>"Sabryna Dooley", "editor_name"=>"Les Nightingill", "updated_on"=>"Sep 11, 2017", "url"=>"/en/complaints/175/notes/1105"}], "assigns"=>[{"date"=>"Aug 1, 2017", "name"=>"Ash Bowe"}, {"date"=>"Mar 5, 2017", "name"=>"Daphne Will"}], "current_assignee_id"=>24, "current_assignee_name"=>"Ash Bowe", "date"=>"Sep 11, 2017", "date_of_birth"=>nil, "current_status_humanized"=>"Open", "attached_documents"=>[{"id"=>160, "complaint_id"=>175, "file_id"=>"9292d2557f464918d233358bc53f928fd347598dd50e7a17e68a403ea687", "title"=>"Home Institutions Governance For Social", "filesize"=>38965, "filename"=>"major_other_apfasiapacificforumnet.docx", "lastModifiedDate"=>"2017-07-27T00:00:00.000Z", "original_type"=>"application/pdf", "user_id"=>nil, "url"=>"/en/complaint_documents/160", "serialization_key"=>"complaint[complaint_documents_attributes][]"}], "mandate_ids"=>[], "good_governance_complaint_basis_ids"=>[1, 2], "special_investigations_unit_complaint_basis_ids"=>[9, 10], "human_rights_complaint_basis_ids"=>[3, 7], "status_changes"=>[{"user_name"=>"Melvina Bartell", "date"=>"2017-09-11T14:28:30.753Z", "status_humanized"=>"Open"}], "agency_ids"=>[872, 885], "communications"=>[{"id"=>36, "complaint_id"=>175, "user_id"=>23, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:30.390Z", "note"=>nil, "user"=>{"id"=>23, "first_last_name"=>"Les Nightingill"}, "attached_documents"=>[{"id"=>30, "communication_id"=>36, "file_id"=>"a0aa5dcbeb9aa4adea9e37681b7c919a3e981d7b4833182cbed2a24faa30", "title"=>"molestias minima nulla qui commodi et fugiat laudantium", "filesize"=>11229, "filename"=>"et_ipsam.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>38, "name"=>"Dimitri Zemlak", "title_key"=>"Dr", "email"=>"maxime@vonjaskolski.co", "phone"=>"(917) 240-5384", "address"=>"38947 Orie Fort", "organization_id"=>24}]}, {"id"=>35, "complaint_id"=>175, "user_id"=>17, "direction"=>"sent", "mode"=>"face to face", "date"=>"2017-09-11T14:28:30.345Z", "note"=>nil, "user"=>{"id"=>17, "first_last_name"=>"Sabrina Hettinger"}, "attached_documents"=>[{"id"=>29, "communication_id"=>35, "file_id"=>"f2a79e3ce25a9aeee9d49a900d4b9010a01feffbf0bae283ade55bd27f7b", "title"=>"facilis consequuntur dolorem libero sit sit enim odit", "filesize"=>22395, "filename"=>"harum_nihil.pdf", "lastModifiedDate"=>nil, "original_type"=>"application/pdf", "user_id"=>nil}], "communicants"=>[{"id"=>37, "name"=>"Gustave Quigley", "title_key"=>"Dr", "email"=>"hermina@vandervort.net", "phone"=>"943-187-5756 x4554", "address"=>"669 Dolores Hill", "organization_id"=>22}]}]}
#  ]
