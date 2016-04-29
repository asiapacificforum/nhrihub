require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/good_governance_context_projects_spec_helpers'
require_relative '../helpers/projects_spec_common_helpers'

feature "projects index", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "projects"

  it "should show a list of projects" do
    expect(page_heading).to eq "#{heading_prefix} Projects"
    expect(page_title).to eq "#{heading_prefix} Projects"
    expect(project_model.count).to eq 3
    expect(projects_count).to eq 3
  end

  it "should add a project" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')
    #check('Human Rights')
    #check('Special Investigations Unit')

    within good_governance_types do
      check('Consultation')
    end

    #within human_rights_types do
      #check('Awareness Raising')
    #end

    within agencies do
      check('MJCA')
    end

    within conventions do
      check('ICERD')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    #page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    page.execute_script("scrollTo(0,0)")
    expect{ save_project.click; sleep(0.3) }.to change{ project_model.count }.from(3).to(4)
    project = GoodGovernance::Project.last
    expect(project.performance_indicator_ids).to eq [pi.id]
    expect(projects_count).to eq 4
    expect(project.title).to eq "new project title"
    expect(project.description).to eq "new project description"
    mandate = Mandate.find_by(:key => "good_governance")
    expect(project.mandate_ids).to include mandate.id
    expand_first_project
    within first_project do
      expect(find('.title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('.mandate .name').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.type').map(&:text)).to include 'Consultation'
        end
      end
      within agencies do
        expect(all('.agency').map(&:text)).to include "MJCA"
      end
      within conventions do
        expect(all('.convention').map(&:text)).to include "ICERD"
      end
      within performance_indicators do
        expect(find('.performance_indicator').text).to eq pi.indexed_description
      end
    end
  end

  it "should restore list when cancelling add project" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    cancel_project.click
    expect(projects_count).to eq 3
    add_project.click
    expect(page.find('#project_title').value).to eq ""
    expect(page.find('#project_description').value).to eq ""
  end

  it "should show warning and not add when title is blank" do
    add_project.click
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; sleep(0.3) }.not_to change{ project_model.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when title is whitespace" do
    add_project.click
    fill_in('project_title', :with => "    ")
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; sleep(0.3) }.not_to change{ project_model.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when description is blank" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    expect{ save_project.click; sleep(0.3) }.not_to change{ project_model.count }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should show warning and not add when description is whitespace" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "   ")
    expect{ save_project.click; sleep(0.3) }.not_to change{ project_model.count }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should prevent adding more than one project at a time" do
    add_project.click
    add_project.click
    expect(page.all('.new_project').count).to eq 1
    cancel_project.click
    expect(page.all('.new_project').count).to eq 0
    add_project.click
    expect(page.all('.new_project').count).to eq 1
  end

  it "should delete a project" do
    expect{ delete_project_icon.click; sleep(0.3)}.to change{ project_model.count }.by(-1).
                                                   and change{ projects_count }.by(-1)
  end

  it "should edit a project" do
    edit_first_project.click
    sleep(0.3) # css transition
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')
    check('Human Rights')

    within good_governance_types do
      check('Consultation')
    end

    within human_rights_types do
      check('Amicus Curiae')
    end

    within agencies do
      check('SAA')
    end

    within conventions do
      check('CEDAW')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    #page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    page.execute_script("scrollTo(0,0)")
    expect{ edit_save.click; sleep(0.3) }.to change{ project_model.find(1).title }.to("new project title")
    project = project_model.find(1)
    consultation_project_type = ProjectType.find_by(:name => "Consultation")
    expect( project.project_type_ids ).to include consultation_project_type.id
    amicus_project_type = ProjectType.find_by(:name => "Amicus Curiae")
    expect( project.project_type_ids ).to include amicus_project_type.id
    agency = Agency.find_by(:name => "SAA")
    expect( project.agency_ids ).to include agency.id
    convention = Convention.find_by(:name => "CEDAW")
    expect( project.convention_ids ).to include convention.id

    expand_first_project

    within first_project do
      expect(find('.title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('.mandate .name').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.type').map(&:text)).to include 'Consultation'
        end
      end
      within agencies do
        expect(all('.agency').map(&:text)).to include "SAA"
      end
      within conventions do
        expect(all('.convention').map(&:text)).to include "CEDAW"
      end
      within performance_indicators do
        expect(all('.performance_indicator').map(&:text)).to include pi.indexed_description
      end
    end
  end

  it "should edit a project and remove performance indicators" do
    edit_first_project.click
    sleep(0.3) # css transition
    expect{ remove_first_indicator.click; sleep(0.3) }.to change{ ProjectPerformanceIndicator.count }.by(-1).
                                                       and change{ page.all('.performance_indicator').count }.by(-1)
  end

  # test this b/c of special handling of checkboxes in ractive
  it "should edit a project and save when all checkboxes are unchecked" do
    edit_last_project.click # has all associations checked
    uncheck_all_checkboxes
    project = project_model.last
    expect{ edit_save.click; sleep(0.4) }.to change{project.project_type_ids}.to([]).
                                          and change{project.agency_ids}.to([]).
                                          and change{project.convention_ids}.to([]).
                                          and change{project.mandate_ids}.to([])
  end

  it "should restore prior values if editing is cancelled" do
    edit_first_project.click
    sleep(0.3) # css transition
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')
    check('Human Rights')

    within good_governance_types do
      check('Consultation')
    end

    within human_rights_types do
      check('Amicus Curiae')
    end

    within agencies do
      check('SAA')
    end

    within conventions do
      check('CEDAW')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator

    edit_cancel

    expand_first_project

    project = project_model.first
    within first_project do
      expect(find('.title').text).to eq project.title
      expect(find('.description .no_edit span').text).to eq project.description
      expect(all('.mandate .name').count).to eq 0
      expect(all('#project_types .type').count).to eq 0
      expect(all('#agencies .agency').count).to eq 0
      expect(all('#conventions .convention').count).to eq 0
      expect(all('.performance_indicator').count).to eq project.performance_indicator_ids.count
    end

    edit_first_project.click
    sleep(0.3) # css transition

    expect(page.find('#project_title').value).to eq project.title
    expect(page.find('#project_description').value).to eq project.description
    expect(checkbox('good_governance')).not_to be_checked
    expect(checkbox('human_rights')).not_to be_checked
    expect(checkbox('project_type_1')).not_to be_checked
    expect(checkbox('project_type_2')).not_to be_checked
    expect(checkbox('project_type_3')).not_to be_checked
    expect(checkbox('project_type_4')).not_to be_checked
    expect(checkbox('project_type_5')).not_to be_checked
    expect(checkbox('agency_1')).not_to be_checked
    expect(checkbox('agency_2')).not_to be_checked
    expect(checkbox('convention_1')).not_to be_checked
    expect(checkbox('convention_2')).not_to be_checked
  end

  #it "should show warning and not add when title is blank" do
    #expect(2).to eq 3
  #end

  #it "should show warning and not add when title is whitespace" do
    #expect(2).to eq 3
  #end

  #it "should show warning and not add when description is blank" do
    #expect(2).to eq 3
  #end

  #it "should show warning and not add when description is whitespace" do
    #expect(2).to eq 3
  #end

  #it "should terminate adding if editing is initiated" do
    #expect(2).to eq 3
  #end

  #it "should terminate editing if adding is initiated" do
    #expect(2).to eq 3
  #end

  #it "should prevent editing more than one project at at time" do
    #expect(2).to eq 3
  #end

  #it "should not permit duplicate performance indicator associations to be added" do
  #  expect(2).to eq 5
  #end
end

feature "projects file upload features", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "projects_fileupload"

  it "should upload files" do
    expect(1).to eq 3
  end
end

feature "projects index filter", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include GoodGovernanceContextProjectsSpecHelpers
  include ProjectsSpecCommonHelpers
  #it_behaves_like "projects_filter"
  it "should filter the view" do
    expect(1).to eq 2
  end
end
