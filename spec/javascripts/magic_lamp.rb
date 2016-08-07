require_relative './projects_seed_data'
require_relative './complaints_seed_data'

MagicLamp.define do
  fixture(:name => "projects") do
    ProjectsSeedData.initialize(:projects)
    {:projects => Project.all, :mandates => Mandate.all}
  end

  fixture(:name => "model_name") do
    Project.to_s
  end

  fixture(:name => "agencies") do
    ProjectsSeedData.initialize(:agencies)
    Agency.all
  end

  fixture(:name => "conventions") do
    ProjectsSeedData.initialize(:conventions)
    Convention.all
  end

  fixture(:name => "project_named_documents_titles") do
    ProjectDocument::NamedProjectDocumentTitles
  end

  fixture(:name => 'projects_page') do
    render :file => 'projects/index'
  end

  fixture(:name => 'project_types') do
    ProjectsSeedData.initialize(:project_types)
    ProjectType.all
  end

  fixture(:name => 'project_filter_criteria') do
    { :title => "",
      :mandate_ids => [],
      :mandate_rule => 'any',
      :agency_ids => [],
      :convention_ids => [],
      :agency_convention_rule => 'any',
      :project_type_ids => [],
      :project_type_rule => 'any',
      :performance_indicator_id => nil
    }
  end

  fixture(:name => 'complaint_filter_criteria') do
    {:complainant => "",
    :from => nil,
    :to => nil,
    :case_ref => "",
    :village => "",
    :phone_number => "",
    :basis_rule => nil,
    :agency_rule => nil,
    :basis_ids => [],
    :selected_agency_ids => [],
    :current_assignee_id => "",
    :selected_assignee_id => "",
    :selected_closed_status => ["true"],
    :selected_open_status => ["true"],
    :selected_human_rights_complaint_basis_ids => [],
    :selected_special_investigations_unit_complaint_basis_ids => [],
    :selected_good_governance_complaint_basis_ids => []}
  end

  fixture(:name => 'complaints_page') do
    render :file => 'complaints/index'
  end

  fixture(:name => 'all_good_governance_complaint_bases') do
    ComplaintsSeedData.initialize(:good_governance_complaint_bases)
    GoodGovernance::ComplaintBasis.all
  end

  fixture(:name => 'all_human_rights_complaint_bases') do
    ComplaintsSeedData.initialize(:human_rights_complaint_bases)
    Nhri::ComplaintBasis.all
  end

  fixture(:name => 'all_special_investigations_unit_complaint_bases') do
    ComplaintsSeedData.initialize(:special_investigations_unit_complaint_bases)
    Siu::ComplaintBasis.all
  end

  fixture(:name => 'all_staff') do
    ComplaintsSeedData.initialize(:staff_users)
    User.staff
  end

  fixture(:name => 'complaints_data') do
    ComplaintsSeedData.initialize(:complaints_data)
    Complaint.all
  end
end
