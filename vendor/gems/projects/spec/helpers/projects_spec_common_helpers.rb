require 'rspec/core/shared_context'
require 'projects_spec_setup_helpers'

module ProjectsSpecCommonHelpers
  extend RSpec::Core::SharedContext
  include ProjectsSpecSetupHelpers

  def add_a_performance_indicator
    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator
    PerformanceIndicator.first
  end

  def add_a_unique_performance_indicator
    select_performance_indicators.click
    select_second_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator
  end

  def click_the_download_icon
    page.all('#project_documents .project_document .fa-cloud-download')[0].click
  end

  def reset_permitted_filetypes
    page.execute_script("projects.set('permitted_filetypes',[])")
  end

  def set_permitted_filetypes
    page.execute_script("projects.set('permitted_filetypes',['anything'])")
  end

  def upload_file_path(filename)
    CapybaraRemote.upload_file_path(page,filename)
  end

  def upload_document
    upload_file_path('first_upload_file.pdf')
  end

  def big_upload_document
    upload_file_path('big_upload_file.pdf')
  end

  def upload_image
    upload_file_path('first_upload_image_file.png')
  end

  def good_governance_types
    page.find('#good_governance_types')
  end

  def human_rights_types
    page.find('#human_rights_types')
  end

  def single_item_selector
    "#projects .project"
  end

  def projects_count
    page.all(single_item_selector).count
  end
  alias_method :number_of_rendered_projects, :projects_count

  def number_of_all_projects
    page.all(single_item_selector, :visible => false).count
  end

  def add_project
    page.find('#add_project')
  end

  def save_project
    page.find('#save_project')
  end

  def cancel_project
    page.find('#cancel_project')
  end

  def first_project
    page.all('#projects .project')[0]
  end

  def last_project
    page.all('#projects .project')[1]
  end

  def areas
    find('#areas')
  end

  def edit_documents
    find('.documents .edit')
  end

  def project_types
    find('#area_project_types')
  end

  def good_governance_area
    page.find(:xpath, ".//div[contains(@class,'area_project_type')][div[contains(.,'Good Governance')]]")
  end

  def agencies
    all('#agencies').first
  end

  def conventions
    conventions_top = page.evaluate_script("$('#conventions').offset().top")
    page.execute_script("scrollTo(0,#{conventions_top})")
    all('#conventions').first
  end

  def new_project
    page.find('.new_project')
  end

  def expand_first_project
    sleep(0.5) # seems to be necessary in order for bootstrap collapse('show') to be called
    page.all('.project .actions #expand')[0].click
  end

  def expand_last_project
    sleep(0.5) # seems to be necessary in order for bootstrap collapse('show') to be called
    page.all('.project .actions #expand')[1].click
  end

  def delete_project_icon
    page.all('.project .delete_icon')[0]
  end

  def delete_file
    page.all('#project_documents .project_document .delete_icon')[0]
  end

  def edit_save
    page.execute_script("scrollTo(0,0)")
    page.find('i.fa-check')
  end

  def edit_first_project
    page.all('.project .icon .fa-pencil-square-o')[0]
  end

  def edit_last_project
    page.all('.project .icon .fa-pencil-square-o').last
  end

  def select_performance_indicators
    # because it was off the page!
    coordinates = page.evaluate_script("$('.performance_indicator_select>a').offset()")
    top = coordinates["top"]
    top = top - 100
    page.execute_script("scrollTo(0,#{top})")
    page.find('.performance_indicator_select>a')
  end

  def select_first_planned_result
    sleep(0.1)
    page.execute_script("$('.dropdown-backdrop').remove()") # it's inserted by bootstrap due to phantomjs declaring that it's responds to document.documentElement.ontouch
    expect(page).to have_selector(".dropdown-submenu.planned_result") # to synchronize the timing
    page.all(".dropdown-submenu.planned_result").first.hover
  end

  def select_second_planned_result
    sleep(0.1)
    page.execute_script("$('.dropdown-backdrop').remove()") # it's inserted by bootstrap due to phantomjs declaring that it's responds to document.documentElement.ontouch
    expect(page).to have_selector(".dropdown-submenu.planned_result") # to synchronize the timing
    page.all(".dropdown-submenu.planned_result")[1].hover
  end

  def select_first_outcome
    sleep(0.1)
    page.all(".dropdown-submenu.outcome").first.hover
  end

  def select_first_activity
    sleep(0.1)
    page.all(".dropdown-submenu.activity").first.hover
  end

  def select_first_performance_indicator
    sleep(0.2)
    page.all("li.performance_indicator").first.click
  end

  def performance_indicators
    page.find('#performance_indicators')
  end

  def remove_first_indicator
    page.all('.selected_performance_indicator .remove')[0]
  end

  def uncheck_all_checkboxes
    sleep(0.3)
    page.
      all(:xpath, "//input[@type='checkbox']").
      each{|cb| uncheck(cb["id"]) }
  end

  def edit_cancel
    page.execute_script("scrollTo(0,0)")
    if page.evaluate_script('navigator.userAgent').match(/phantomjs/i)
      # when the performance_indicator dropdown is still active, phantomjs can't
      # click on the icon due to dropdown backdrop being present
      page.find("#project_editable1_edit_cancel").trigger('click')
    else
      #selenium has no problem, finding the icon
      #but it doesn't support 'trigger'
      page.find('#project_editable1_edit_cancel').click
    end
  end

  def checkbox(id)
    page.find(:xpath, "//input[@type='checkbox'][@id='#{id}']")
  end

  def click_the_download_icon
    page.all("#projects .project .project_document .fa-cloud-download")[0].click
  end

  def project_documents
    page.find('#project_documents')
  end
end
