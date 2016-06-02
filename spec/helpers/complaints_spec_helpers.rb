require 'rspec/core/shared_context'

module ComplaintsSpecHelpers
  extend RSpec::Core::SharedContext
  def cancel_add
    page.find('#cancel_complaint').click
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

  def edit_save
    page.find('.fa-check').click
  end

  def check_basis(group, text)
    basis_checkbox(group, text).set(true)
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
    page.find('#save_complaint')
  end

  def new_complaint_case_reference
    page.find('.new_complaint #case_reference').text
  end

  def complaint_categories
    page.find('#complaint_categories')
  end

  def first_complaint
    page.all('#complaints .complaint')[0]
  end

  def complaint_documents
    page.find('#complaint_documents')
  end

  def assignee_history
    find('#assignees')
  end

  def expand
    all('#expand').first.click
  end

  def add_complaint
    page.find('#add_complaint').click
  end
end
