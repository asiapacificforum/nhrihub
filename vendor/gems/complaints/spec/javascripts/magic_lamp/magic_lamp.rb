require_relative './seed_data/complaints_seed_data'

MagicLamp.define do

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
    :selected_good_governance_complaint_basis_ids => [],
    :selected_statuses => []}
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

  fixture(:name => 'statuses') do
    ComplaintsSeedData.initialize(:statuses)
    ComplaintStatus.select(:id, :name).all
  end
end
