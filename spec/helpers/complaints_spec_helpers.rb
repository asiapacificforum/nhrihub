require 'rspec/core/shared_context'

module ComplaintsSpecHelpers
  extend RSpec::Core::SharedContext
  def check_basis(group, text)
    within "##{group}_bases" do
      find(:xpath, ".//div[@class='row complaint_basis'][.//span[contains(.,'#{text}')]]").find('input').set(true)
    end
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
    find('#expand').click
  end

  def add_complaint
    page.find('#add_complaint')
  end
end
