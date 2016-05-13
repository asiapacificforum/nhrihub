require 'rspec/core/shared_context'

module ProjectsSpecCommonHelpers
  extend RSpec::Core::SharedContext
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

  # it's a test spec workaround, this method can be called multiple times
  # whereas page.attach_file cannot
  # UPDATE: after eliminating jQuery.fileupload, this doesn't seem to be required
  # it's left here for reference
  def attach_file(index = nil)
    page.attach_file("project_fileinput", upload_document, :visible => false)
    #page.attach_file("project_file", upload_document, :visible => false)
    #if !index # when it's first time, we pass a truthy argument like :first_time
      #if page.evaluate_script('navigator.userAgent').match(/phantomjs/i)
        ## because the change event is not triggered when the same file is attached again,
        ## so must trigger it manually in a test scenario (or else use many different files)
        ## #project_fileinput and project_file both refer to the same element
        ## with id=project_fileinput and name=project_file
        #page.execute_script("$('#project_fileinput').trigger('change')")
      #end
    #end
  end

  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    end
  end

  def populate_mandates
    #["good_governance", "human_rights", "special_investigations_unit"].each do |key|
    ["good_governance"].each do |key|
      Mandate.create(:key => key)
    end
  end

  def populate_types
    gg = Mandate.find_or_create_by(:key => 'good_governance')
    hr = Mandate.find_or_create_by(:key => 'human_rights')
    #siu = Mandate.find_or_create_by(:key => 'special_investigations_unit')

    #gg_types = ["Own motion investigation", "Consultation", "Awareness Raising", "Other"]
    gg_types = [ "Consultation", "Awareness Raising"]
    gg_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => gg.id)
    end

    #hr_types = ["Schools", "Report or Inquiry", "Awareness Raising", "Legislative Review",
                #"Amicus Curiae", "Convention Implementation", "UN Reporting", "Detention Facilities Inspection",
                #"State of Human Rights Report", "Other"]
    hr_types = ["Schools", "Amicus Curiae", "State of Human Rights Report"]
    hr_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => hr.id)
    end

    #siu_types = ["PSU Review", "Report", "Inquiry", "Other"]
    #siu_types.each do |type|
      #ProjectType.create(:name => type, :mandate_id => siu.id)
    #end
  end

  def populate_agencies
    agencies = {
    "MJCA" => "Ministry of Justice and Courts Administration",
    "SAA" => "Samoa Airport Authority"#,
    #"MAF" => "Ministry of Agriculture and Fisheries",
    #"MNRE" => "Ministry of Natural Resources and Environment",
    #"LTA" => "Land Transport Authority",
    #"SFESA" => "Fire and Emergency Services Authority",
    #"SNPF" => "Samoa National Provident Fund",
    #"MCIL" => "Ministry of Commerce Industry and Labour",
    #"ACC" => "Accident Compensation Corporation"
    }.each do |short,full|
      Agency.create(:name => short, :full_name => full)
    end
  end

  def populate_conventions
    conventions = {
    "ICERD" => "International Convention on the Elimination of All Forms of Racial Discrimination",
    #"ICCPR" => "International Covenant on Civil and Political Rights",
    #"ICESCR" => "International Covenant on Economic, Social and Cultural Rights",
    "CEDAW" => "Convention on the Elimination of All Forms of Discrimination against Women"#,
    #"CAT" => "Convention against Torture and Other Cruel, Inhuman or Degrading Treatment or Punishment",
    #"CRC" => "Convention on the Rights of the Child",
    #"ICMW" => "International Convention on the Protection of the Rights of All Migrant Workers and Members of Their Families",
    #"CPED" => "International Convention for the Protection of All Persons from Enforced Disappearance",
    #"CRPD" => "Convention on the Rights of Persons with Disabilities"
    }.each do |short,full|
      Convention.create(:name => short, :full_name => full)
    end
  end

  def good_governance_types
    page.find('#good_governance_types')
  end

  def human_rights_types
    page.find('#human_rights_types')
  end

  def projects_count
    page.all('#projects .project').count
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

  def mandates
    find('#mandates')
  end

  def edit_documents
    find('.documents .edit')
  end

  def project_types
    find('#mandate_project_types')
  end

  def good_governance_mandate
    page.find(:xpath, ".//div[contains(@class,'mandate_project_type')][div[contains(.,'Good Governance')]]")
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
    page.all('#expand')[0].click
    #sleep(0.5) # css transition
  end

  def expand_last_project
    sleep(0.5) # seems to be necessary in order for bootstrap collapse('show') to be called
    page.all('#expand')[1].click
    #sleep(0.5) # css transition
  end

  def delete_project_icon
    page.all('.project .delete_icon')[0]
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

  def setup_strategic_plan
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    a1 = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    a2 = Activity.create(:description => "Public outreach", :outcome_id => o.id)
    a3 = Activity.create(:description => "Media coverage", :outcome_id => o.id)
    p1 = PerformanceIndicator.create(:description => "Happier people", :target => "90%", :activity_id => a1.id)
    p2 = PerformanceIndicator.create(:description => "More wealth", :target => "80%", :activity_id => a2.id)
    p3 = PerformanceIndicator.create(:description => "Greater justice", :target => "70%", :activity_id => a3.id)
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

  def project_documents
    page.find('#project_documents')
  end
end
