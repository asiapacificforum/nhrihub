require 'rspec/core/shared_context'
require 'application_helpers'
require 'reminders_spec_common_helpers'
require 'notes_spec_common_helpers'
require 'complaints_reminders_setup_helpers'

module ComplaintsSpecHelpers
  extend RSpec::Core::SharedContext
  include ApplicationHelpers
  include RemindersSpecCommonHelpers
  include NotesSpecCommonHelpers

  def add_a_communication
    open_communications_modal
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      set_datepicker('new_communication_date',"May 19, 2016")
      sleep(0.2)
      choose("Email")
      choose("Sent")
      expect(page).to have_selector("#email_address")
      fill_in("email_address", :with => "norm@normco.com")
      add_communicant
      page.all('input.communicant')[0].set("Harry Harker")
      page.all(:css, 'input#email_address')[0].set("harry@acme.com")
      fill_in("note", :with => "Some note text")
    end
    save_communication
  end

  def delete_a_communication
    page.find("#communications .communication .delete_icon").click
    confirm_deletion
    wait_for_ajax
  end

  def add_a_note
    add_note.click
    expect(page).to have_selector("#new_note #note_text")
    fill_in(:note_text, :with => "nota bene")
    save_note.click
    wait_for_ajax
    close_notes_modal
  end

  def add_a_reminder
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    page.find('#reminder_start_date_1i') # forces wait until the element is available
    select_date("Aug 19 #{Date.today.year.next}", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_id)
    fill_in(:reminder_text, :with => "time to check the database")
    save_reminder.click
    wait_for_ajax
    close_reminders_modal
  end

  def click_the_download_icon
    scroll_to(page.all('#complaint_documents .complaint_document .fa-cloud-download')[0]).click
  end

  def new_complaint
    page.find('.new_complaint')
  end

  def delete_complaint
    page.find('.delete_icon').click
  end

  def delete_document
    scroll_to(page.all('#complaint_documents .complaint_document i.delete_icon').first).click
  end

  def cancel_add
    find('#cancel_complaint').click
  end

  def edit_cancel
    page.find('.edit_cancel .fa-remove').click
  end

  def current_status
    page.find('#current_status')
  end

  def status_changes
    page.find('#status_changes')
  end

  def status
    page.find('.status')
  end

  def edit_complaint
    page.find('.actions .fa-pencil-square-o').click
  end

  def deselect_file
    page.find('#edit_communication #communication_documents .document i.remove').click
  end

  def edit_first_complaint
    scroll_to(page.all('.actions .fa-pencil-square-o')[0]).click
  end

  def edit_second_complaint
    sleep(0.2) # while the first complaint edit panel is opening
    # b/c where this is used, the first complaint edit icon has been removed when this is called, so the second edit complaint is actually the first!
    edit_first_complaint
  end

  def select_male_gender
    choose('m')
  end

  def edit_save
    find('.save_complaint').click
    wait_for_ajax
  end

  def check_agency(text)
    within page.find("#agencies_select") do
      check(text)
    end
  end

  def uncheck_agency(text)
    within page.find("#agencies_select") do
      uncheck(text)
    end
  end

  def uncheck_mandate(text)
    uncheck(text)
  end

  def check_basis(group, text)
    basis_checkbox(group, text).set(true)
  end

  def uncheck_basis(group, text)
    basis_checkbox(group, text).set(false)
  end

  def basis_checkbox(group, text)
    within "##{group}_bases" do
      find(:xpath, ".//div[@class='row complaint_basis'][.//span[contains(.,'#{text}')]]").find('input')
    end
  end

  def good_governance_complaint_bases
    page.find('#good_governance_complaint_bases')
  end

  def human_rights_complaint_bases
    page.find('#human_rights_complaint_bases')
  end

  def special_investigations_unit_complaint_bases
    page.find('#special_investigations_unit_complaint_bases')
  end

  def save_complaint
    find('#save_complaint')
  end

  def new_complaint_case_reference
    page.find('.new_complaint #case_reference').text
  end

  def agencies
    page.find('#agencies')
  end

  def first_complaint
    complaints[0]
  end

  def complaint_documents
    page.find('#complaint_documents')
  end

  def complaints
    page.all('#complaints .complaint')
  end

  def number_of_rendered_complaints
    complaints.length
  end

  def number_of_all_complaints
    page.all('#complaints .complaint', :visible => false).length
  end

  def documents
    page.all('#complaint_documents .complaint_document')
  end

  def assignee_history
    find('#assignees')
  end

  def expand
    sleep(0.4)
    all('.complaint #expand').first.click
  end

  def add_complaint
    find('#add_complaint').click
  end

  def open_communications_modal
    page.find('.case_reference', :text => Complaint.first.case_reference) # hack to make sure the page is loaded and rendered
    page.all('#complaints .complaint .fa-comments-o')[0].click
  end

  def select_datepicker_date(id,year,month,day)
    month = month -1 # js month  monthis 0-indexed
    page.execute_script %Q{ $('#{id}').trigger('focus') } # trigger datepicker
    page.execute_script("$('.ui-datepicker-month').prop('selectedIndex',#{month}).trigger('change')")
    year_index = page.evaluate_script("_($('.ui-datepicker-year option')).map(function(o){return o.text})").map(&:to_i).find_index(year)
    page.execute_script("$('.ui-datepicker-year').prop('selectedIndex',#{year_index}).trigger('change')")
    page.execute_script("target=$('#ui-datepicker-div td[data-month=#{month}][data-year=#{year}] a').filter(function(){return $(this).text()==#{day}})[0]")
    page.execute_script("$(target).trigger('click')")
    #page.evaluate_script %Q{ $('#{id}').datepicker('hide') } # trigger the onClose handler
  end
end
