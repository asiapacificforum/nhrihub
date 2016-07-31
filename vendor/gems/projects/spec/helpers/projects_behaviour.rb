require 'navigation_helpers'
require 'projects_spec_common_helpers'
require 'upload_file_helpers'

RSpec.shared_examples "projects index" do
  include IERemoteDetector
  include NavigationHelpers
  include ProjectsSpecCommonHelpers
  include UploadFileHelpers

  it "should show a list of projects" do
    expect(page_heading).to eq "Projects"
    expect(page_title).to eq "Projects"
    expect(Project.count).to eq 2
    expect(projects_count).to eq 2
  end

  it "shows expanded information for each of the projects" do
    expand_last_project
    within last_project do
      last_project = Project.find(2)
      expect(find('.basic_info .title').text).to eq last_project.title
      expect(find('.description .no_edit span').text).to eq last_project.description
      last_project.mandates.each do |mandate|
        expect(all('#mandates .mandate').map(&:text)).to include mandate.name
      end
      within project_types do
        within good_governance_mandate do
          last_project.good_governance_project_types.each do |project_type|
            expect(all('.project_type').map(&:text)).to include project_type.name
          end
        end
      end
      within agencies do
        last_project.agencies.each do |agency|
          expect(all('.agency').map(&:text)).to include agency.name
        end
      end
      within conventions do
        last_project.conventions.each do |convention|
          expect(all('.convention').map(&:text)).to include convention.name
        end
      end
      within performance_indicators do
        last_project.performance_indicators.each do |performance_indicator|
          expect(all('.performance_indicator').map(&:text)).to include performance_indicator.indexed_description
        end
      end
      within project_documents do
        last_project.project_documents.each do |project_document|
          expect(all('.project_document .title').map(&:text)).to include project_document.title
        end
      end
    end
  end

  it "adds a project that does not have a file attachment" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')

    within good_governance_types do
      check('Consultation')
    end

    within agencies do
      check('MJCA')
    end

    within conventions do
      convention = Convention.where(:name => "ICERD").first
      puts page.evaluate_script("$('#convention_#{convention.id}').first().offset()")
      check('ICERD')
    end

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    # SAVE IT
    page.execute_script("scrollTo(0,0)")
    expect{ save_project.click; wait_for_ajax }.to change{ Project.count }.from(2).to(3)

    # CHECK SERVER
    pi = PerformanceIndicator.first
    project = Project.last
    expect(project.performance_indicator_ids).to eq [pi.id]
    expect(projects_count).to eq 3
    expect(project.title).to eq "new project title"
    expect(project.description).to eq "new project description"
    mandate = Mandate.find_by(:key => "good_governance")
    expect(project.mandate_ids).to include mandate.id

    # CHECK CLIENT
    expand_first_project
    within first_project do
      expect(find('.project .basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('#mandates .mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
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

  it "adds a project that has a file attachment" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    check('Good Governance')

    within good_governance_types do
      check('Consultation')
    end

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
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    within new_project do
      attach_file("project_fileinput", upload_document)
      fill_in("project_document_title", :with => "Project Document")
    end
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf")

    within new_project do
      attach_file("project_fileinput", upload_document)
      page.all("#project_document_title")[0].set("Title for an analysis document")
    end
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 2)

    # SAVE IT
    page.execute_script("scrollTo(0,0)")
    expect{ save_project.click; wait_for_ajax }.to change{ Project.count }.from(2).to(3).
                                             and change{ ProjectDocument.count }.by(2)

    # CHECK SERVER
    pi = PerformanceIndicator.first
    project = Project.last
    expect(project.performance_indicator_ids).to eq [pi.id]
    expect(projects_count).to eq 3
    expect(project.title).to eq "new project title"
    expect(project.description).to eq "new project description"
    mandate = Mandate.find_by(:key => "good_governance")
    expect(project.mandate_ids).to include mandate.id

    expect(project.project_documents.count).to eq 2
    expect(project.project_documents.map(&:title)).to include "Project Document"
    expect(project.project_documents.map(&:title)).to include "Title for an analysis document"

    # CHECK CLIENT
    expand_first_project
    within first_project do
      expect(find('.basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('#mandates .mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
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
      within project_documents do
        expect(all('.project_document .title').map(&:text)).to include "Project Document"
        expect(all('.project_document .title').map(&:text)).to include "Title for an analysis document"
      end
    end
  end

  it "flags as invalid when file attachment exceeds permitted filesize" do
    add_project.click

    within new_project do
      attach_file("project_fileinput", big_upload_document)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")

    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
  end

  it "flags as invalid when file attachment is unpermitted filetype" do
    add_project.click

    within new_project do
      attach_file("project_fileinput", upload_image)
    end
    expect(page).to have_css('#filetype_error', :text => "File type not allowed")

    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
  end

  it "should restore list when cancelling add project" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "new project description")
    cancel_project.click
    expect(projects_count).to eq 2
    add_project.click
    expect(page.find('#project_title').value).to eq ""
    expect(page.find('#project_description').value).to eq ""
  end

  it "should remove performance indicator from the list during adding" do
    add_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    remove_first_indicator.click
    wait_for_ajax
    expect(page).not_to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
  end

  it "should prevent adding duplicate performance indicators" do
    add_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector(".new_project #performance_indicators .selected_performance_indicator", :text => pi.indexed_description)

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator
    pi = PerformanceIndicator.first

    expect(page).to have_selector(".new_project #performance_indicators .selected_performance_indicator", :text => pi.indexed_description, :count => 1)
  end

  it "should show warning and not add when title is blank" do
    add_project.click
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when title is whitespace" do
    add_project.click
    fill_in('project_title', :with => "    ")
    fill_in('project_description', :with => "new project description")
    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not add when description is blank" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should show warning and not add when description is whitespace" do
    add_project.click
    fill_in('project_title', :with => "new project title")
    fill_in('project_description', :with => "   ")
    expect{ save_project.click; wait_for_ajax }.not_to change{ Project.count }
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
    expect{ delete_project_icon.click; wait_for_ajax }.to change{ Project.count }.by(-1).
                                                   and change{ projects_count }.by(-1)
  end

  it "should edit a project with a file" do
    edit_first_project.click
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

    attach_file("project_fileinput", upload_document)
    fill_in("project_document_title", :with => "Adding another doc")
    expect(page).to have_selector("#project_documents .document .filename", :text => "upload_file.pdf")

    attach_file("project_fileinput", upload_document)
    page.all("#project_document_title")[0].set("Adding still another doc")
    expect(page).to have_selector("#project_documents .document .filename", :text => "upload_file.pdf", :count => 2)

    expect{ edit_save.click; wait_for_ajax }.to change{ Project.find(1).title }.to("new project title")
    project = Project.find(1)
    consultation_project_type = ProjectType.find_by(:name => "Consultation")
    expect( project.project_type_ids ).to include consultation_project_type.id
    amicus_project_type = ProjectType.find_by(:name => "Amicus Curiae")
    expect( project.project_type_ids ).to include amicus_project_type.id
    agency = Agency.find_by(:name => "SAA")
    expect( project.agency_ids ).to include agency.id
    convention = Convention.find_by(:name => "CEDAW")
    expect( project.convention_ids ).to include convention.id
    expect( project.project_documents.count ).to eq 4

    expand_first_project

    within first_project do
      expect(find('.basic_info .title').text).to eq "new project title"
      expect(find('.description .no_edit span').text).to eq "new project description"
      expect(all('.mandate').map(&:text)).to include 'Good Governance'
      within project_types do
        within good_governance_mandate do
          expect(all('.project_type').map(&:text)).to include 'Consultation'
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
      within project_documents do
        expect(all('.project_document .title').map(&:text)).to include "Adding still another doc"
        expect(all('.project_document .title').map(&:text)).to include "Adding another doc"
      end
    end
  end

  it "should edit a project and remove performance indicators" do
    edit_first_project.click
    expect{ remove_first_indicator.click; wait_for_ajax }.to change{ ProjectPerformanceIndicator.count }.by(-1).
                                                       and change{ page.all('.selected_performance_indicator').count }.by(-1)
  end

  # test this b/c of special handling of checkboxes in ractive
  it "should edit a project and save when all checkboxes are unchecked" do
    edit_last_project.click # has all associations checked
    uncheck_all_checkboxes
    project = Project.last
    expect{ edit_save.click; wait_for_ajax }.to change{project.project_type_ids}.to([]).
                                          and change{project.agency_ids}.to([]).
                                          and change{project.convention_ids}.to([]).
                                          and change{project.mandate_ids}.to([])
  end

  it "should restore prior values if editing is cancelled" do
    edit_first_project.click
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

    project = Project.first
    within first_project do
      expect(find('.basic_info .title').text).to eq project.title
      expect(find('.description .no_edit span').text).to eq project.description
      expect(all('.mandate .name').count).to eq 0
      expect(all('#project_types .project_type').count).to eq 0
      expect(all('#agencies .agency').count).to eq 0
      expect(all('#conventions .convention').count).to eq 0
      expect(all('.performance_indicator').count).to eq project.performance_indicator_ids.count
    end

    edit_first_project.click

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

  it "should show warning and not save when editing and title is blank" do
    edit_first_project.click
    fill_in('project_title', :with => '')
    expect{ edit_save.click; wait_for_ajax }.not_to change{ Project.find(1).title }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not save edited project when title is whitespace" do
    edit_first_project.click
    fill_in('project_title', :with => "   ")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ Project.find(1).title }
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in('project_title', :with => 't')
    expect(page).not_to have_selector("#title_error", :text => "Title cannot be blank")
  end

  it "should show warning and not save edited project when description is blank" do
    edit_first_project.click
    fill_in('project_description', :with => "")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ Project.find(1).description }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should show warning and not save edited project when description is whitespace" do
    edit_first_project.click
    fill_in('project_description', :with => "  ")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ Project.find(1).description }
    expect(page).to have_selector("#description_error", :text => "Description cannot be blank")
    fill_in('project_description', :with => 't')
    expect(page).not_to have_selector("#description_error", :text => "Description cannot be blank")
  end

  it "should terminate adding if editing is initiated" do
    add_project.click
    expect(page).to have_selector('.new_project')
    edit_first_project.click
    expect(page).not_to have_selector('.new_project')
  end

  it "should terminate editing if adding is initiated" do
    edit_first_project.click
    expect(page).to have_selector('#projects .project textarea#project_description', :visible => true)
    add_project.click
    expect(page).not_to have_selector('#projects .project textarea#project_description', :visible => true)
  end

  it "should prevent editing more than one project at at time" do
    edit_first_project.click
    edit_last_project.click
    expect(page).to have_selector('#projects .project textarea#project_description', :visible => true, :count => 1)
  end

  it "should not permit duplicate performance indicator associations to be added when editing" do
    edit_first_project.click

    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    #page.execute_script("scrollTo(0,800)")
    select_first_performance_indicator

    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :count => 3)
  end

  it "should download a project document file" do
    expand_first_project
    @doc = ProjectDocument.first
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      puts "disregard, it's fake"
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end
end
