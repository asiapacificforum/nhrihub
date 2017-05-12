require 'rspec/core/shared_context'

module ComplaintsSpecHelpers
  extend RSpec::Core::SharedContext
  def click_the_download_icon
    page.all('#complaint_documents .complaint_document .fa-cloud-download')[0].click
  end

  def new_complaint
    page.find('.new_complaint')
  end

  def delete_complaint
    page.find('.delete_icon').click
  end

  def delete_document
    page.all('#complaint_documents .complaint_document i.delete_icon').first.click
  end

  def cancel_add
    page.execute_script("scrollTo(0,0)")
    page.find('#cancel_complaint').click
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
    page.all('.actions .fa-pencil-square-o')[0].click
  end

  def edit_second_complaint
    # b/c where this is used, the first complaint has been removed whe this is called, so the second edit complaint is actually the first!
    edit_first_complaint
  end

  def select_male_gender
    page.execute_script("scrollTo(0,0)")
    choose('m')
  end

  def edit_save
    #page.execute_script("scrollTo(0,0)")
    page.find('.save_complaint').click
    wait_for_ajax
  end

  def check_agency(text)
    within page.find("#agencies") do
      check(text)
    end
  end

  def uncheck_agency(text)
    within page.find("#agencies") do
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
    #page.execute_script("scrollTo(0,0)")
    page.find('#save_complaint')
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
    all('.complaint #expand').first.click
  end

  def add_complaint
    page.find('#add_complaint').click
  end

  def open_communications_modal
    page.all('#complaints .complaint .fa-comments-o')[0].click
  end

  def select_datepicker_date(id,year,month,day)
    month = month -1 # js month  monthis 0-indexed
    page.execute_script %Q{ $('#{id}').trigger('focus') } # trigger datepicker
    page.execute_script("target=$('#ui-datepicker-div td[data-month=#{month}][data-year=#{year}] a').filter(function(){return $(this).text()==#{day}})[0]")
    page.execute_script("$(target).trigger('click')")
    #page.evaluate_script %Q{ $('#{id}').datepicker('hide') } # trigger the onClose handler
  end
end
